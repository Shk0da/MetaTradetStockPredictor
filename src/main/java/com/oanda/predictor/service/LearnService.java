package com.oanda.predictor.service;

import akka.actor.ActorRef;
import akka.actor.ActorSystem;
import akka.actor.Props;
import com.google.common.collect.Maps;
import com.oanda.predictor.actor.LearnActor;
import com.oanda.predictor.actor.Messages;
import com.oanda.predictor.actor.SpringDIActor;
import com.oanda.predictor.domain.Candle;
import com.oanda.predictor.repository.CandleRepository;
import com.oanda.predictor.repository.PredictionRepository;
import lombok.Synchronized;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class LearnService {

    private final Map<String, ActorRef> actors = Maps.newConcurrentMap();

    @Autowired
    private CandleRepository candleRepository;

    @Autowired
    private PredictionRepository predictionRepository;

    private final ActorSystem actorSystem = ActorSystem.create("LearnSystem");

    @Async
    @Synchronized
    public void addCandle(Candle candle) {
        candleRepository.addCandle(candle);

        ActorRef actor = actors.getOrDefault(candle.getKey(), null);
        if (actor == null) {
            actor = actorSystem.actorOf(Props.create(SpringDIActor.class, LearnActor.class, candle.getSymbol(), candle.getStep()), "LearnActor_" + candle.getSymbol() + "_" + candle.getStep());
            actors.put(candle.getKey(), actor);
        }

        actor.tell(Messages.LEARN, actorSystem.guardian());
    }

    public String getPredict(String symbol, int step) {
        ActorRef actor = actors.getOrDefault(symbol + step, null);
        if (actor != null) {
            actor.tell(Messages.WORK, actorSystem.guardian());
        }

        return predictionRepository.getPredict(symbol);
    }
}