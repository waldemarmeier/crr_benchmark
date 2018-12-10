cppFunction("double CRRcpp(const std::string& optionType , double undly_price, double strike, double time,
                             double risk_free_rate, double dividend_yield, double std, int periods ) { 
            
            double typeFlag = -1;
            
            if(optionType==\"ce\"  || optionType==\"ca\" ){
            typeFlag = 1;
            }
            
            
            double dt = time/periods;
            double u  = exp( std * sqrt(dt) );
            double d  = 1/u;
            double p  = ( exp((risk_free_rate-dividend_yield)*dt)-d)/(u-d);
            double Df = exp(-risk_free_rate*dt);
            
            double bin_tree [periods+1];
            
            for (int i = 0;i<=periods;i++){
            
            double temp = typeFlag * ( undly_price * pow (u,i) * pow (d,periods-i) - strike );
            
            if (temp>0){
            bin_tree[i] = temp;
            } else {
            bin_tree[i] = 0;
            }
            }
            
            if(optionType==\"ce\" || optionType==\"pe\"){
            for (int j =periods-1;j>=0;j--){
            
            for (int i =0;i<=j;i++){
            
            bin_tree[i] = (p * bin_tree[i+1] + (1-p) * bin_tree[i])*Df;
            
            }
            
            }
            
            return bin_tree[0];
            
            } else if (optionType==\"ca\" || optionType==\"pa\"){

      for (int j =periods-1;j>=0;j--){
  
        for (int i =0;i<=j;i++){
        
            bin_tree[i] = std::max(  typeFlag * (undly_price* pow (u,i) * pow (d,  abs(i-j)) - strike )  , 
                                    (p * bin_tree[i+1] + (1-p) * bin_tree[i])*Df);

          }
        
        }
        
        return bin_tree[0];

   } else {
      return -1;
   }
    
  return -1;
  }")