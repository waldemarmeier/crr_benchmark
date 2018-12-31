
public class CRR {

    public static double crr(String type, double undly_price, double strike, double time,
                             double risk_free_rate, double dividend_yield, double std, int periods){

        double typeFlag = -1;

        if (type.toLowerCase().equals("ca") || type.toLowerCase().equals("ce")){
            typeFlag = 1;
        }


        double dt = time/periods;
        double u  = Math.exp( std * Math.sqrt(dt) );
        double d  = 1/u;
        double p  = (Math.exp((risk_free_rate-dividend_yield)*dt)-d)/(u-d);
        double Df =  Math.exp(-risk_free_rate*dt);

        double [] bin_tree = new double[periods+1];

        for (int i = 0;i<=periods;i++){

            double temp = typeFlag * ( undly_price * Math.pow(u,i) * Math.pow(d,periods-i) - strike );

            if (temp>0){
                bin_tree[i] = temp;
            } else {
                bin_tree[i] = 0;
            }
        }



        if (type.toLowerCase().equals("ce") || type.toLowerCase().equals("pe")){

            for (int j =periods-1;j>=0;j--){

                for (int i =0;i<=j;i++){

                    //System.out.println("i: "+i);
                    bin_tree[i] = (p * bin_tree[i+1] + (1-p) * bin_tree[i])*Df;

                }

            }

            return bin_tree[0];

        } else if (type.toLowerCase().equals("ca") || type.toLowerCase().equals("pa")){

            for (int j =periods-1;j>=0;j--){

                for (int i =0;i<=j;i++){

                    //System.out.println("i: "+i);
                    //double ex =  Math.abs(i-j);
                    //double ew = (p * bin_tree[i+1] + (1-p) * bin_tree[i])*Df;
                    bin_tree[i] = Math.max(  typeFlag * (undly_price*Math.pow(u,i) * Math.pow(d, Math.abs(i-j)) - strike )  ,
                                                        (p * bin_tree[i+1] + (1-p) * bin_tree[i])*Df);

                    //System.out.println("abs(i-j) "+Math.abs(i-j));


                }

            }

            return bin_tree[0];

        }

        return -1;

    }


}
