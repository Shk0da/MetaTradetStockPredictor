//+------------------------------------------------------------------+
#define MAGICMA  20180214
//--- Inputs
input string Host          ="http://localhost/";
input double BalanceRisk   =30;
input double BalanceLimit  =50;
input double MinimumLots   =0.01;
input double SFPofit       =0.0031;
input double MaximumSpread =30;
input double TP            =0;
input double SL            =0;

input bool   TSEnable      =true;
input int    TSVal         =5;
input int    TSStep        =5;

int prevsignal=0;
static datetime LastBarOpenAt;
//+------------------------------------------------------------------+
void init()
  {
   int bars = (Bars < 5000) ? Bars : 5000;
   for(int i=bars; i>0; i--)
     {
      string json=StringConcatenate("{",
                                    "\"time\"",
                                    ":",
                                    "\"",
                                    iTime(Symbol(),0,i)*1000,
                                    "\"",
                                    ",",
                                    "\"symbol\"",
                                    ":",
                                    "\"",
                                    Symbol(),
                                    "\"",
                                    ",",
                                    "\"step\"",
                                    ":",
                                    "\"",
                                    Period(),
                                    "\"",
                                    ",",
                                    "\"bid\"",
                                    ":",
                                    "\"",
                                    0,
                                    "\"",
                                    ",",
                                    "\"ask\"",
                                    ":",
                                    "\"",
                                    0,
                                    "\"",
                                    ",",
                                    "\"open\"",
                                    ":",
                                    "\"",
                                    iOpen(Symbol(),0,i),
                                    "\"",
                                    ",",
                                    "\"high\"",
                                    ":",
                                    iHigh(Symbol(),0,i),
                                    ",",
                                    "\"low\"",
                                    ":",
                                    iLow(Symbol(),0,i),
                                    ",",
                                    "\"close\"",
                                    ":",
                                    iClose(Symbol(),0,i),
                                    ",",
                                    "\"value\"",
                                    ":",
                                    iVolume(Symbol(),0,i),
                                    "}"
                                    );

      char post_data[];
      StringToCharArray(json,post_data,0,StringLen(json));
      char results[];
      string result_header;
      ResetLastError();
      int result= WebRequest("POST",Host + "/api/add-candle","Content-Type: application/json\r\n",5000,post_data,results,result_header);
      if(result == -1) Print("Error in WebRequest. Error code: ",GetLastError());
     }
  }
//+------------------------------------------------------------------+
void OnTick()
  {
   int signal=0;
   if(LastBarOpenAt!=Time[0])
     {
      LastBarOpenAt=Time[0];
      string json=StringConcatenate("{",
                                    "\"time\"",
                                    ":",
                                    "\"",
                                    TimeCurrent()*1000,
                                    "\"",
                                    ",",
                                    "\"symbol\"",
                                    ":",
                                    "\"",
                                    Symbol(),
                                    "\"",
                                    ",",
                                    "\"step\"",
                                    ":",
                                    "\"",
                                    Period(),
                                    "\"",
                                    ",",
                                    "\"bid\"",
                                    ":",
                                    "\"",
                                    Bid,
                                    "\"",
                                    ",",
                                    "\"ask\"",
                                    ":",
                                    "\"",
                                    Ask,
                                    "\"",
                                    ",",
                                    "\"open\"",
                                    ":",
                                    "\"",
                                    iOpen(Symbol(),0,0),
                                    "\"",
                                    ",",
                                    "\"high\"",
                                    ":",
                                    iHigh(Symbol(),0,0),
                                    ",",
                                    "\"low\"",
                                    ":",
                                    iLow(Symbol(),0,0),
                                    ",",
                                    "\"close\"",
                                    ":",
                                    iClose(Symbol(),0,0),
                                    ",",
                                    "\"value\"",
                                    ":",
                                    iVolume(Symbol(),0,0),
                                    "}"
                                    );

      char post_data[];
      StringToCharArray(json,post_data,0,StringLen(json));
      char results[];
      string result_header;
      ResetLastError();
      int result= WebRequest("POST",Host + "/api/add-candle","Content-Type: application/json\r\n",5000,post_data,results,result_header);
      if(result == -1) Print("Error in WebRequest. Error code: ",GetLastError());

      signal=CalculaSignal();
     }

   int ordenes=0;
   double sfprofit=AccountBalance()*SFPofit;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA && (OrderType()==OP_BUY || OrderType()==OP_SELL))
           {
            if(prevsignal==0)
              {
               if(OrderType()==OP_BUY) prevsignal=1;
               if(OrderType()==OP_SELL) prevsignal=-1;
              }
            double profit=OrderProfit()+OrderSwap()-OrderCommission();
            if(((prevsignal>0 && signal<0) || (prevsignal<0 && signal>0)) || (profit>=sfprofit))
              {
               if(OrderType()==OP_BUY) OrderClose(OrderTicket(),OrderLots(),Bid,3,Red);
               if(OrderType()==OP_SELL) OrderClose(OrderTicket(),OrderLots(),Ask,3,Red);
              }
            else
              {
               ordenes++;
               if(TSEnable) TrailingPositions();
              }
           }
        }
     }

   if(signal == 0) return;

   double tp=TP*MarketInfo(Symbol(),MODE_POINT);
   double sl=SL*MarketInfo(Symbol(),MODE_POINT);
   double spread=MarketInfo(Symbol(),MODE_ASK)-MarketInfo(Symbol(),MODE_BID);
   if(ordenes==0 && signal>0)
     {
      if(OrderSend(Symbol(),OP_BUY,CalcularVolumen(),Ask,0,sl!=0?Ask-sl:0,tp!=0?Ask+spread+tp:0,"",MAGICMA,0,Blue))
        {
         prevsignal=signal;
        }
     }

   if(ordenes==0 && signal<0)
     {
      if(OrderSend(Symbol(),OP_SELL,CalcularVolumen(),Bid,0,sl!=0?Bid+sl:0,tp!=0?Bid-spread-tp:0,"",MAGICMA,0,Red))
        {
         prevsignal=signal;
        }
     }
  }
//+------------------------------------------------------------------+
double CalcularVolumen()
  {
   double aux=MinimumLots*MathFloor(BalanceRisk*AccountFreeMargin()/100000/MinimumLots);

   double free=AccountFreeMargin();
   double margin=MarketInfo(Symbol(),MODE_MARGINREQUIRED);
   double step= MarketInfo(Symbol(),MODE_LOTSTEP);
   double lot = MathFloor(free*BalanceRisk/100/margin/step)*step;
   double max=(lot*margin>free) ? 0 : lot;

   if(aux>max) aux=max;
   if(aux<MinimumLots) aux=MinimumLots;
   if(aux>MarketInfo(Symbol(),MODE_MAXLOT)) aux=MarketInfo(Symbol(),MODE_MAXLOT);
   if(aux<MarketInfo(Symbol(),MODE_MINLOT)) aux=MarketInfo(Symbol(),MODE_MINLOT);

   return(aux);
  }
//+------------------------------------------------------------------+
void TrailingPositions()
  {
   double pBid,pAsk;
   double val=TSVal;
   double pp=MarketInfo(OrderSymbol(),MODE_POINT);
   int stop_level=MarketInfo(Symbol(),MODE_STOPLEVEL)+MarketInfo(Symbol(),MODE_SPREAD);
   if(OrderType()==OP_BUY)
     {
      pBid=MarketInfo(OrderSymbol(),MODE_BID);
      if((pBid-OrderOpenPrice())>val*pp)
        {
         if(OrderStopLoss()<pBid-(val+TSStep-1)*pp)
           {
            double ldStopLossBuy=pBid-val*pp;
            double ldTakeProfitBuy=OrderTakeProfit()>0 ? OrderTakeProfit()+TSStep*MarketInfo(OrderSymbol(),MODE_POINT) : 0;
            OrderModify(OrderTicket(),OrderOpenPrice(),ldStopLossBuy,ldTakeProfitBuy,0,CLR_NONE);
            return;
           }
        }
     }
   if(OrderType()==OP_SELL)
     {
      pAsk=MarketInfo(OrderSymbol(),MODE_ASK);
      if(OrderOpenPrice()-pAsk>val*pp)
        {
         if(OrderStopLoss()>pAsk+(val+TSStep-1)*pp || OrderStopLoss()==0)
           {
            double ldStopLossSell=pAsk+val*pp;
            double ldTakeProfitSell=OrderTakeProfit()>0 ? OrderTakeProfit()+TSStep*MarketInfo(OrderSymbol(),MODE_POINT)*-1 : 0;
            OrderModify(OrderTicket(),OrderOpenPrice(),ldStopLossSell,ldTakeProfitSell,0,CLR_NONE);
            return;
           }
        }
     }
  }
//+------------------------------------------------------------------+
double CalculaSignal()
  {
   if(AccountBalance()<=BalanceLimit) return 0;
   if(MarketInfo(Symbol(), MODE_SPREAD) > MaximumSpread * MarketInfo(Symbol(), MODE_DIGITS)) return 0;

   ResetLastError();
   string headers;
   char results[],body[];
   int result= WebRequest("GET", Host + "/api/prediction?symbol="+Symbol()+"&step="+Period(),"Content-Type: application/json\r\n",5000,body,results,headers);
   if(result == -1) Print("Error in WebRequest. Error code: ",GetLastError());
   string predict=CharArrayToString(results);

   if(predict == "UP") return 1;
   if(predict == "DOWN") return -1;

   return 0;
  }
//+------------------------------------------------------------------+
