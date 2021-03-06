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

input int    sense         =2;
input bool   learn         =false;

int prevsignal=0;
static datetime LastBarOpenAtM1;
static datetime LastBarOpenAtM5;
static datetime LastBarOpenAtM15;
static datetime LastBarOpenAtM30;
//+------------------------------------------------------------------+
void sendData(string json)
  {
   char post_data[];
   StringToCharArray(json,post_data,0,StringLen(json));
   char results[];
   string result_header;
   ResetLastError();
   int result= WebRequest("POST",Host + "/api/add-candle","Content-Type: application/json\r\n",5000,post_data,results,result_header);
   if(result == -1) Print("Error in WebRequest. Error code: ",GetLastError());
  }
//+------------------------------------------------------------------+
void init()
  {
   if(!learn) return;
   int bars = (Bars < 5000) ? Bars : 5000;
   for(int i=bars; i>0; i--)
     {
      string json;
      // PERIOD_M1
      json=StringConcatenate("{","\"time\"",":","\"",iTime(Symbol(),PERIOD_M1,i)*1000,"\"",",","\"symbol\"",":","\"",Symbol(),"\"",",","\"step\"",":","\"",PERIOD_M1,"\"",",","\"bid\"",":","\"",0,"\"",",","\"ask\"",":","\"",0,"\"",",","\"open\"",":","\"",iOpen(Symbol(),PERIOD_M1,i),"\"",",","\"high\"",":",iHigh(Symbol(),PERIOD_M1,i),",","\"low\"",":",iLow(Symbol(),PERIOD_M1,i),",","\"close\"",":",iClose(Symbol(),PERIOD_M1,i),",","\"value\"",":",iVolume(Symbol(),PERIOD_M1,i),"}");
      sendData(json);
      // PERIOD_M5
      json=StringConcatenate("{","\"time\"",":","\"",iTime(Symbol(),PERIOD_M5,i)*1000,"\"",",","\"symbol\"",":","\"",Symbol(),"\"",",","\"step\"",":","\"",PERIOD_M5,"\"",",","\"bid\"",":","\"",0,"\"",",","\"ask\"",":","\"",0,"\"",",","\"open\"",":","\"",iOpen(Symbol(),PERIOD_M5,i),"\"",",","\"high\"",":",iHigh(Symbol(),PERIOD_M5,i),",","\"low\"",":",iLow(Symbol(),PERIOD_M5,i),",","\"close\"",":",iClose(Symbol(),PERIOD_M5,i),",","\"value\"",":",iVolume(Symbol(),PERIOD_M5,i),"}");
      sendData(json);
      // PERIOD_M15
      json=StringConcatenate("{","\"time\"",":","\"",iTime(Symbol(),PERIOD_M15,i)*1000,"\"",",","\"symbol\"",":","\"",Symbol(),"\"",",","\"step\"",":","\"",PERIOD_M15,"\"",",","\"bid\"",":","\"",0,"\"",",","\"ask\"",":","\"",0,"\"",",","\"open\"",":","\"",iOpen(Symbol(),PERIOD_M15,i),"\"",",","\"high\"",":",iHigh(Symbol(),PERIOD_M15,i),",","\"low\"",":",iLow(Symbol(),PERIOD_M15,i),",","\"close\"",":",iClose(Symbol(),PERIOD_M15,i),",","\"value\"",":",iVolume(Symbol(),PERIOD_M15,i),"}");
      sendData(json);
      // PERIOD_M30
      json=StringConcatenate("{","\"time\"",":","\"",iTime(Symbol(),PERIOD_M30,i)*1000,"\"",",","\"symbol\"",":","\"",Symbol(),"\"",",","\"step\"",":","\"",PERIOD_M30,"\"",",","\"bid\"",":","\"",0,"\"",",","\"ask\"",":","\"",0,"\"",",","\"open\"",":","\"",iOpen(Symbol(),PERIOD_M30,i),"\"",",","\"high\"",":",iHigh(Symbol(),PERIOD_M30,i),",","\"low\"",":",iLow(Symbol(),PERIOD_M30,i),",","\"close\"",":",iClose(Symbol(),PERIOD_M30,i),",","\"value\"",":",iVolume(Symbol(),PERIOD_M30,i),"}");
      sendData(json);
     }
  }
//+------------------------------------------------------------------+
void OnTick()
  {
   int signal=0;
   string json;

// PERIOD_M1
   if(LastBarOpenAtM1!=iTime(Symbol(),PERIOD_M1,0))
     {
      LastBarOpenAtM1=iTime(Symbol(),PERIOD_M1,0);
      json=StringConcatenate("{","\"time\"",":","\"",iTime(Symbol(),PERIOD_M1,0)*1000,"\"",",","\"symbol\"",":","\"",Symbol(),"\"",",","\"step\"",":","\"",PERIOD_M1,"\"",",","\"bid\"",":","\"",Bid,"\"",",","\"ask\"",":","\"",Ask,"\"",",","\"open\"",":","\"",iOpen(Symbol(),PERIOD_M1,0),"\"",",","\"high\"",":",iHigh(Symbol(),PERIOD_M1,0),",","\"low\"",":",iLow(Symbol(),PERIOD_M1,0),",","\"close\"",":",iClose(Symbol(),PERIOD_M1,0),",","\"value\"",":",iVolume(Symbol(),PERIOD_M1,0),"}");
      sendData(json);
      signal=CalculaSignal();
     }

// PERIOD_M5
   if(LastBarOpenAtM5!=iTime(Symbol(),PERIOD_M5,0))
     {
      LastBarOpenAtM5=iTime(Symbol(),PERIOD_M5,0);
      json=StringConcatenate("{","\"time\"",":","\"",iTime(Symbol(),PERIOD_M5,0)*1000,"\"",",","\"symbol\"",":","\"",Symbol(),"\"",",","\"step\"",":","\"",PERIOD_M5,"\"",",","\"bid\"",":","\"",Bid,"\"",",","\"ask\"",":","\"",Ask,"\"",",","\"open\"",":","\"",iOpen(Symbol(),PERIOD_M5,0),"\"",",","\"high\"",":",iHigh(Symbol(),PERIOD_M5,0),",","\"low\"",":",iLow(Symbol(),PERIOD_M5,0),",","\"close\"",":",iClose(Symbol(),PERIOD_M5,0),",","\"value\"",":",iVolume(Symbol(),PERIOD_M5,0),"}");
      sendData(json);
      signal=CalculaSignal();
     }

// PERIOD_M15
   if(LastBarOpenAtM15!=iTime(Symbol(),PERIOD_M15,0))
     {
      LastBarOpenAtM15=iTime(Symbol(),PERIOD_M15,0);
      json=StringConcatenate("{","\"time\"",":","\"",iTime(Symbol(),PERIOD_M15,0)*1000,"\"",",","\"symbol\"",":","\"",Symbol(),"\"",",","\"step\"",":","\"",PERIOD_M15,"\"",",","\"bid\"",":","\"",Bid,"\"",",","\"ask\"",":","\"",Ask,"\"",",","\"open\"",":","\"",iOpen(Symbol(),PERIOD_M15,0),"\"",",","\"high\"",":",iHigh(Symbol(),PERIOD_M15,0),",","\"low\"",":",iLow(Symbol(),PERIOD_M15,0),",","\"close\"",":",iClose(Symbol(),PERIOD_M15,0),",","\"value\"",":",iVolume(Symbol(),PERIOD_M15,0),"}");
      sendData(json);
      signal=CalculaSignal();
     }

// PERIOD_M30
   if(LastBarOpenAtM30!=iTime(Symbol(),PERIOD_M30,0))
     {
      LastBarOpenAtM30=iTime(Symbol(),PERIOD_M30,0);
      json=StringConcatenate("{","\"time\"",":","\"",iTime(Symbol(),PERIOD_M30,0)*1000,"\"",",","\"symbol\"",":","\"",Symbol(),"\"",",","\"step\"",":","\"",PERIOD_M30,"\"",",","\"bid\"",":","\"",Bid,"\"",",","\"ask\"",":","\"",Ask,"\"",",","\"open\"",":","\"",iOpen(Symbol(),PERIOD_M30,0),"\"",",","\"high\"",":",iHigh(Symbol(),PERIOD_M30,0),",","\"low\"",":",iLow(Symbol(),PERIOD_M30,0),",","\"close\"",":",iClose(Symbol(),PERIOD_M30,0),",","\"value\"",":",iVolume(Symbol(),PERIOD_M30,0),"}");
      sendData(json);
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

   int predictSum=0;

   ResetLastError();
   string headers,predict,comment;
   char results[],body[];
   int result;

// PERIOD_M1
   result=WebRequest("GET",Host+"/api/prediction?symbol="+Symbol()+"&step="+PERIOD_M1,"Content-Type: application/json\r\n",5000,body,results,headers);
   if(result==-1) Print("Error in WebRequest. Error code: ",GetLastError());
   predict=CharArrayToString(results);
   if(predict == "UP") predictSum++;
   if(predict == "DOWN") predictSum--;
   comment="PERIOD_M1: "+predict+"\n";

// PERIOD_M5
   result=WebRequest("GET",Host+"/api/prediction?symbol="+Symbol()+"&step="+PERIOD_M5,"Content-Type: application/json\r\n",5000,body,results,headers);
   if(result==-1) Print("Error in WebRequest. Error code: ",GetLastError());
   predict=CharArrayToString(results);
   if(predict == "UP") predictSum++;
   if(predict == "DOWN") predictSum--;
   comment+="PERIOD_M5: "+predict+"\n";

// PERIOD_M15
   result=WebRequest("GET",Host+"/api/prediction?symbol="+Symbol()+"&step="+PERIOD_M15,"Content-Type: application/json\r\n",5000,body,results,headers);
   if(result==-1) Print("Error in WebRequest. Error code: ",GetLastError());
   predict=CharArrayToString(results);
   if(predict == "UP") predictSum++;
   if(predict == "DOWN") predictSum--;
   comment+="PERIOD_M15: "+predict+"\n";

// PERIOD_M30
   result=WebRequest("GET",Host+"/api/prediction?symbol="+Symbol()+"&step="+PERIOD_M30,"Content-Type: application/json\r\n",5000,body,results,headers);
   if(result==-1) Print("Error in WebRequest. Error code: ",GetLastError());
   predict=CharArrayToString(results);
   if(predict == "UP") predictSum++;
   if(predict == "DOWN") predictSum--;
   comment+="PERIOD_M30: "+predict+"\n";

   Comment("\n"+comment);

   return predictSum >= sense ? 1 : (predictSum <= -sense ? -1 : 0);
  }
//+------------------------------------------------------------------+
