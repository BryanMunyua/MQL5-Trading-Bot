#include <Trade/Trade.mqh>

CTrade trade;

ulong posTicket;

int start;

input double lotSize = 0.01;

input double pendingOrderLotSize = 0.01;

input double riskPercentage = 0.175;

input double pendingOrderRiskPercentage = 0.175;

input double pendingOrderStopLossPips = 7;

input double pendingOrderPipsforPricePosition = 20;

double stopLossPips = 15;

double previousBuyStopLoss = 0;
double previousSellStopLoss = 0;
double previousBuyTakeProfit = 0;
double previousSellTakeProfit = 0;
double previousBuyPrice = 0;
double previousSellPrice = 0;


double previousBuyTakeprofitArray[2];


double previousSellTakeProfitArray[2];


double previousBuyStopLossArray[2];


double previousSellStopLossArray[2];



int OnInit()
  {
   
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {

  }

void OnTick()
  {   
      static datetime timestamp;
      datetime time = iTime(_Symbol,PERIOD_CURRENT,0);
      
      if(timestamp != time){
      
      timestamp = time;
      
      string symbol = Symbol(); // Get the current symbol of the chart
      double lastPrice = SymbolInfoDouble(symbol, SYMBOL_LAST); // Get the current last price (close price)
   
      Print("Current Last Price of ", symbol, ": ", lastPrice);
      Print("Previous Buy Price is: ",previousBuyPrice);
      Print("Previous Buy Take Profit is: ",previousBuyTakeProfit);
      Print("Previous Buy Stop Loss is: ",previousBuyStopLoss);
      Print("Previous Sell Price is: ",previousSellPrice);
      Print("Previous Sell Take Profit is: ",previousSellTakeProfit);
      Print("Previous Sell Stop Loss is: ",previousSellStopLoss);
      


      
      double ask3 = SymbolInfoDouble(_Symbol,SYMBOL_BID);
      double bid3 = SymbolInfoDouble(_Symbol,SYMBOL_BID);
      
      if(start == 1 && lastPrice >= previousBuyPrice && previousBuyPrice>0){
         Print("Buy trade has begun");
         
         
         
         if(lastPrice <= previousBuyStopLoss && previousBuyStopLoss>0){
         
            Print("Buy stop loss hit");
            Print("This is because the last price: ", lastPrice," was less than the previous buy sl: ", previousBuyStopLoss);
            
            double ask = SymbolInfoDouble(_Symbol,SYMBOL_BID);
            double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
            double sl = bid + (stopLossPips*10)* SymbolInfoDouble(_Symbol,SYMBOL_POINT);
            double tp = bid - 40*riskPercentage*10*SymbolInfoDouble(_Symbol,SYMBOL_POINT);
            double price = ask - pendingOrderPipsforPricePosition*10*SymbolInfoDouble(_Symbol,SYMBOL_POINT);
            double sl2 = price + (pendingOrderStopLossPips*10)* SymbolInfoDouble(_Symbol,SYMBOL_POINT);
            double tp2 = price - 40*pendingOrderRiskPercentage*10* SymbolInfoDouble(_Symbol,SYMBOL_POINT);
            trade.SellStop(lotSize,price,_Symbol,sl2,tp2,ORDER_TIME_DAY,0,"Placed a sell stop order");
            
            
            //Create an array for the price data
            MqlRates PriceInformation[];
            
            //Sort the array from the current candle downwards
            ArraySetAsSeries(PriceInformation,true);
            
            //Fill the price array with data
            int Data=CopyRates(Symbol(),Period(),0,Bars(Symbol(),Period()),PriceInformation);
  
            //Create an arrow upwards
            ObjectCreate(_Symbol,"Horizontal Line",OBJ_HLINE,0,TimeCurrent(),PriceInformation[0].low);

            
            Print("Placed a sell stop order");
            previousBuyPrice = 0;
            previousBuyTakeProfit = 0;
            previousBuyStopLoss = 0;
            
         }else if(lastPrice >= previousBuyTakeProfit && previousBuyTakeProfit>0){
         
            Print("The buy take profit has been hit");
            Print("This is because the last price: ", lastPrice ," is > the previous buy tp: ",previousBuyTakeProfit);
         
            previousBuyPrice = 0;
            previousBuyTakeProfit = 0;
            previousBuyStopLoss = 0;
         
         
         
         }
      }else if(start == 1 && lastPrice <= previousSellPrice && previousSellPrice>0){
         Print("Sell trade has begun");
         
         
         if(lastPrice >= previousSellStopLoss && previousSellStopLoss>0){
            Print("Sell stop loss hit");
            
            Print("This is because the plast price: ", lastPrice," was greater than the previous sell sl: ", previousSellStopLoss);
            
            double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
            double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
            double sl = ask - (stopLossPips*10)* SymbolInfoDouble(_Symbol,SYMBOL_POINT);
            double tp = ask + 40*riskPercentage*10*SymbolInfoDouble(_Symbol,SYMBOL_POINT);
            double price = bid + pendingOrderPipsforPricePosition*10*SymbolInfoDouble(_Symbol,SYMBOL_POINT);
            double sl2 = price - (pendingOrderStopLossPips*10)* SymbolInfoDouble(_Symbol,SYMBOL_POINT);
            double tp2 = price + 40*pendingOrderRiskPercentage*10* SymbolInfoDouble(_Symbol,SYMBOL_POINT);
            trade.BuyStop(lotSize,price,_Symbol,sl2,tp2,ORDER_TIME_DAY,0,"Placed a buy stop trade");
            
            //Create an array for the price data
            MqlRates PriceInformation[];
            
            //Sort the array from the current candle downwards
            ArraySetAsSeries(PriceInformation,true);
            
            //Fill the price array with data
            int Data=CopyRates(Symbol(),Period(),0,Bars(Symbol(),Period()),PriceInformation);
  
            //Create an arrow upwards
            ObjectCreate(_Symbol,"Horizontal Line",OBJ_HLINE,0,TimeCurrent(),PriceInformation[0].low);

            
            Print("Placed a buy stop order");
            previousSellTakeProfit = 0;
            previousSellStopLoss = 0;
            previousSellPrice = 0;
            
            
       }else if(lastPrice <= previousSellTakeProfit && previousSellTakeProfit >0){
       
            Print("Previous sell take profit");
            Print("This is because the previous ask: ",lastPrice," is < the previous sell tp: ",previousSellTakeProfit);
            previousSellTakeProfit = 0;
            previousSellStopLoss = 0;
            previousSellPrice = 0;

            
       
       }
      }
            
      
      double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
      double totalPositions = PositionsTotal();
      

      static double initialBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      

      ENUM_TIMEFRAMES currentPeriod = Period();
      // Use the timeframe of your choice

      // Get the open price of the previous candle
      static double previousOpen = iOpen(_Symbol, currentPeriod, 1);
      
      double currentHigh = iHigh(Symbol(), Period(), 0);
    
    

      // Get the close price of the previous candle
      static double previousClose = iClose(_Symbol, currentPeriod, 1);
      
      double currentLow = iLow(Symbol(), Period(), 0);

      double previousHighValueArray[][2];
      double previousLowValueArray[][2];
      
      int arraySize3 = 4;
      
      ArrayResize(previousHighValueArray, arraySize3);
      ArrayResize(previousLowValueArray, arraySize3);
        

      double historicalCandleData[][2]; // Array to store historical candle open and close values
      int arraySize = 4; // Size of the historical data array (number of candles you want to store)
      
      ArrayResize(historicalCandleData, arraySize); // Resize the array to hold 'arraySize' number of candles
      
      double historicalOpenValues[]; // Array to store historical candle open values
      double historicalCloseValues[]; // Array to store historical candle close values
      int arraySize2 = 4; // Size of the historical data array (number of candles you want to store)
      
      ArrayResize(historicalOpenValues, arraySize2);
      
      int counter = 0;
      
      
      for (int i = 0; i < arraySize; i++)
      {
        double openValue = iOpen(Symbol(), Period(), i);   // Open value of the i-th historical candle
        double closeValue = iClose(Symbol(), Period(), i); // Close value of the i-th historical candle

        historicalCandleData[i][0] = openValue;
        historicalCandleData[i][1] = closeValue;
        
        historicalOpenValues[i]=openValue;
        
        double previousHighValue = iHigh(Symbol(), Period(), i);   // Open value of the i-th historical candle
        double previousLowValue = iLow(Symbol(), Period(), i);
         
        previousHighValueArray[i][0] = previousHighValue;
        previousLowValueArray[i][1] = previousLowValue;
        
        
        
        int rows = ArraySize(historicalOpenValues); // Number of rows
        
        counter += 1;
        
        
        if(counter>=4){
            
            
            
           
           if(historicalCandleData[i][0]<historicalCandleData[i][1] && historicalCandleData[i-1][0]<historicalCandleData[i-1][1] 
           && historicalCandleData[i-2][0]>historicalCandleData[i-2][1]){
  
               
               //Create an array for the price data
               MqlRates PriceInformation[];
               
               //Sort the array from the current candle downwards
               ArraySetAsSeries(PriceInformation,true);
               
               //Fill the price array with data
               int Data=CopyRates(Symbol(),Period(),0,Bars(Symbol(),Period()),PriceInformation);
     
               //Create an arrow upwards
               ObjectCreate(_Symbol,"Horizontal Line",OBJ_HLINE,0,TimeCurrent(),PriceInformation[0].low);
   
               double balance = AccountInfoDouble(ACCOUNT_BALANCE);
               
               double equity = AccountInfoDouble(ACCOUNT_EQUITY);
               
               double totalProfits = equity- initialBalance;
               
               double lossIncreamentFactor = 1.0;
                     
               double accountBalanceLimit = 40.0;
               
               int totalPositions = PositionsTotal();
               
               for(int i=1; i<100; i++ ){
               
                     if(totalProfits>=-3.5 && balance <= 40*(i+1) && totalPositions<=0){
                     
                           double ask = SymbolInfoDouble(_Symbol,SYMBOL_BID);
                           double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
                           double sl = bid + (stopLossPips*10)* SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                           double tp = bid - 40*riskPercentage*10* SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                           double price = ask - pendingOrderPipsforPricePosition*10*SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                           double sl2 = price + (pendingOrderStopLossPips*10)* SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                           double tp2 = price - 40*pendingOrderRiskPercentage*10* SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                           trade.SellStop(lotSize*i,price,_Symbol,sl2,tp2,ORDER_TIME_DAY,0,"Placed a sell stop order");
                           previousSellStopLoss = sl2;
                           previousSellTakeProfit = tp2;
                           previousSellPrice = price;
                           start=1;
                           break;
                
                     }else if(totalProfits<=-3.5*i && totalProfits>-3.5* (i+1) && balance <= 40*(i+1)&& totalPositions<=0){
                     
                           double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
                           double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
                           double sl = bid + (stopLossPips*10)* SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                           double tp = bid - 40*riskPercentage*10* SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                           double price = ask - pendingOrderPipsforPricePosition*10*SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                           double sl2 = price + (pendingOrderStopLossPips*10)* SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                           double tp2 = price - 40*pendingOrderRiskPercentage*10* SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                           trade.SellStop(lotSize*(i+1),price,_Symbol,sl2,tp2,ORDER_TIME_DAY,0,"Placed a sell stop order");
                           previousSellStopLoss = sl2;
                           previousSellTakeProfit = tp2;
                           previousSellPrice = price;
                           start=1;
                           break;
                     
                     
                     }else if(totalProfits<=-3.5*i && totalProfits>-3.5* (i+1)
                      && balance <= 40 * (i+2) && balance > 40 * (i+1) && totalPositions<=0){
  
                           double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
                           double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
                           double sl = bid + (stopLossPips*10)* SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                           double tp = bid - 40*(i+1)*riskPercentage*10* SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                           double price = ask - pendingOrderPipsforPricePosition*10*SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                           double sl2 = price + (pendingOrderStopLossPips*10)* SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                           double tp2 = price - 40*(1+i)*pendingOrderRiskPercentage*10* SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                           previousSellStopLoss = sl2;
                           previousSellTakeProfit = tp2;
                           previousSellPrice = price;
                           start=1;
                           trade.SellStop(lotSize*(i+1),price,_Symbol,sl2,tp2,ORDER_TIME_DAY,0,"Placed a sell stop order");
                           break;

               }
               
                     totalPositions = PositionsTotal();
             
               }
     
               
            }else if(historicalCandleData[i][0]>historicalCandleData[i][1] && historicalCandleData[i-1][0]>historicalCandleData[i-1][1]
                     && historicalCandleData[i-2][0]<historicalCandleData[i-2][1]){
            
               
               //Create an array for the price data
               MqlRates PriceInformation[];
            
               //Sort the array from the current candle downwards
               ArraySetAsSeries(PriceInformation,true);
               
               //Fill the price array with data
               int Data=CopyRates(Symbol(),Period(),0,Bars(Symbol(),Period()),PriceInformation);
        
               //Create an arrow downwards
               ObjectCreate(_Symbol,"Horizontal Line",OBJ_HLINE,0,TimeCurrent(),PriceInformation[0].high);
   
               double balance = AccountInfoDouble(ACCOUNT_BALANCE);
               
               double equity = AccountInfoDouble(ACCOUNT_EQUITY);
               
               double totalProfits = equity- initialBalance;
               
               double stopLossLimit = -3.5;
      
               double accountBalanceLimit = 40.0;
               
               int totalPositions = PositionsTotal();
               
               Comment("The total profit is: ", totalProfits);
      
               for(int i=1; i<100;i++){
               
                  if(totalProfits>=-3.5 && balance <= 40*(i+1) && totalPositions<=0){
                     
                        double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
                        double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
                        double sl = ask - (stopLossPips*10)* SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                        double tp = ask + 40*riskPercentage*10* SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                        double price = bid + pendingOrderPipsforPricePosition*10* SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                        double sl2 = price - (pendingOrderStopLossPips*10)* SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                        double tp2 = price + 40*pendingOrderRiskPercentage*10* SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                        trade.BuyStop(lotSize*i,price,_Symbol,sl2,tp2,ORDER_TIME_DAY,0,"Placed a buy stop");
                        previousBuyStopLoss = sl2;
                        previousBuyTakeProfit = tp2;
                        previousBuyPrice = price;
                        start=1;
                        break;


                             
                  }else if(totalProfits<=-3.5*i && totalProfits>-3.5* (i+1) && balance <= 40*(i+1) && totalPositions<=0){
                  
                     
                        double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
                        double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
                        double sl = ask - (stopLossPips*10)* SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                        double tp = ask + 40*riskPercentage*10*SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                        double price = bid + pendingOrderPipsforPricePosition*10*SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                        double sl2 = price - (pendingOrderStopLossPips*10)* SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                        double tp2 = price + 40*pendingOrderRiskPercentage*10* SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                        trade.BuyStop(lotSize*(i+1),price,_Symbol,sl2,tp2,ORDER_TIME_DAY,0,"Placed a buy stop trade");
                        previousBuyStopLoss = sl2;
                        previousBuyTakeProfit = tp2;
                        previousBuyPrice = price;
                        start=1;
                        break;
                  
                  
                  
                  }else if(totalProfits<=-3.5*i && totalProfits>-3.5* (i+1)
                     && balance <= 40 * (i+2) && balance > 40 * (i+1) && totalPositions<=0){

                        double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
                        double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
                        double sl = ask - (stopLossPips*10)* SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                        double tp = ask + 40*(i+1)*riskPercentage*10* SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                        double price = bid + pendingOrderPipsforPricePosition*10*SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                        double sl2 = price - (pendingOrderStopLossPips*10)* SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                        double tp2 = price + 40*(1+i)*pendingOrderRiskPercentage*10* SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                        trade.BuyStop(lotSize*(i+1),price,_Symbol,sl2,tp2,ORDER_TIME_DAY,0,"Placed a buy stop trade");
                        previousBuyStopLoss = sl2;
                        previousBuyTakeProfit = tp2;
                        previousBuyPrice = price;
                        start=1;  
                        break;
                        
                        

                     }
      
               
                  totalPositions = PositionsTotal();
               
               }
            
            }
         }

   }

   }}
   
   
  
  

