module matrixops (
    input            clk,
    input            rst,
    input            enter,
    input      [1:0] X,
    input      [1:0] Y,
    output reg       Z
);

    // 3 states
    parameter IDLE = 2'b00;
    parameter in = 2'b01;
    parameter out = 2'b10;

    //internal variables
    reg [1:0] state;
    reg [2:0] cnt;
    reg [3:0] ent_cnt;
    reg [1:0] prev_Y;
    reg [1:0] prev_X;
    reg  prev_ent;
    reg prev_Z;

 
    // one dimensional matrix structure
    wire [3:0] index = {Y,X};
    reg [15:0] matrix;  
    
    //state transitions
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            cnt <= 3'd0;
            matrix <= 16'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (ent_cnt>=1) begin
                      state <= in;
                      if (enter) begin
                        matrix[index] <= 1'b1; //inserting the first element into matrix
                      end
                
                    end
                end

                in: begin
                    if (cnt < 3'd4 & enter) begin
                        matrix[index] <= 1'b1;  
                        
                    end else if (cnt >= 3'd4)begin
                        state <= out; 
                    end
                end

                out: begin end
            endcase
        end
    end
    
    // Counter implementation which counts the number of enters 
   always @(posedge clk or posedge rst) begin
    if(rst) begin
      ent_cnt <=3'b0;
    end else if (enter) begin
      ent_cnt<= ent_cnt+1;
    end
  end

  //Counter implementation which counts the number of inputs
  always @(posedge clk or posedge rst) begin
    if(rst) begin
        cnt <= 3'd0;
    end
    else if (enter) begin
        if (ent_cnt>= 4'd2) begin
            cnt <= cnt + 3'd1;
        end
    end
  end

  // Updating the previous values 
  always @(negedge clk) begin
    prev_Y<=Y;
    prev_X<=X;
    prev_ent<=enter;
  end

  wire [3:0] prev_idx = {prev_Y,prev_X};

  always @(negedge clk) begin
    if (state == out) begin
      prev_Z<=Z;
    end
  end
   
  // Deciding on output (Z value) by covering all transitions of enter from one phase to another
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            Z <= 1'b0;
        end else if (((!prev_ent & !enter)|(enter==1&prev_ent==0))&(state == out)) begin 
            Z <= prev_Z;
        end else if (state == out & ((prev_ent ^ enter)|(prev_ent==1&enter==1))) begin
            
            Z <= matrix[prev_idx];
        end else begin
            Z <= 1'b0;
    end
end

endmodule