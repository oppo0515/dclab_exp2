/*
  Do: A*B*2^(-256) %N
*/

module Multi( A,
              B,
              N,
              clk,
              start,
              out, 
              done );

  input [255:0] A, B, N;
  input clk;
  input start;  // negedge
  output [255:0] out;
  output done;  // posedge

  reg [255:0] a, b;
  reg [255:0] a1;
  reg [258:0] accu1, accu2, n;
  reg [9:0] i1, i2;
  wire clk2, clk3, clk4;
  reg done;
  
  initial begin
    i1 =0;
    i2 =0;
    done =0;
  end

  always @(negedge start) begin
    accu1 = 258'd0;
    accu2 = 258'd0;
    a = A[255:0];
    b = B[255:0];
    n = { 3'd0, N[255:0] };
    i1 =0;
    i2 =0;
    done =0;
  end
/*
  Do addition and shifting
  100100011100001101 * b %n
>                  b  +/- kn => xxxxxxxxxxxxx0
*/



//  ==== for loop edition ====
  always @(posedge clk) begin
    i2 = i1 +1;
    if ( a1[0] ==1'b1 ) begin
      accu2 = accu1 + b;
    end
    else begin
      accu2 = accu1;
    end
  end

  always @(posedge clk) begin
    if (accu2[0] ==1'b1) begin
      if (accu2 >= n) begin
        accu1 = accu2 - n;
      end
      else begin
        accu1 = accu2 + n;
      end
    end
    else begin
      accu1 = accu2;
    end
  end

  always @(posedge clk) begin
    i1 = i2;
    accu2 = accu1;
  end

  always @(posedge clk) begin
    accu1 = {1'b0, accu2[255:1] };
    a1 = {1'b0, a[255:1] };
  end

//

  always @(a1 ==256'd0) begin
    if (accu1 >=n) begin
      $display("Error");
    end
    $display("out = %h", accu1);
    done =1;
  end

  assign out[255:0] = accu1[255:0];

endmodule

