module ROM #(parameter bit_pix, bit_strok, bit_data_out, bit_data_in)
    input clk,
    input rst,
                                       // input valid, // это не valid_char, как раньше было, это разрешение по y, показывающая его диапазон
                                       // output busy, // ставим в 1 когда последовательно передаем на выход пакет из chars.v
    input                          newline,
    input                          newframe,
    input   [bit_pix        - 1  : 0] y, // счетчики битов и строк
    input   [bit_pix        - 1  : 0] x, 
    input   [bit_strok      - 1  : 0] x0, //начальная точка блока меню(мегафункции константы)
    input   [bit_strok      - 1  : 0] y0,
    input   [bit_data_in    - 1  : 0] input_mode,
    input   [bit_data_in    - 1  : 0] input_Type_AGC,
    input   [bit_data_in    - 1  : 0] input_Set_LVL1,
    input   [bit_data_in    - 1  : 0] input_Set_LVL2,
    input   [bit_data_in    - 1  : 0] input_Time_int,
    output                            menu_window_valid,
    output  [bit_data_out   - 1  : 0] out_data
);
//////////////////////////////////////////////////////////  
wire [7:0] pixels;
reg [5:0] char;
reg out;
wire window = (((x > x0) && x < (x0 + 200)) && (y > y0 && (y < (y0 + 250)))) ? 1 : 0; //Задаем рамки окна меню
reg [2:0] i, j = 0;
reg [2:0] valid;
reg [bit_data_out - 1 : 0] out_data_signal;
reg write_char = 0;
//////////////////////////////////////////////////////////  
assign out_data = out_data_signal;
assign menu_window_valid = window;
////////////////////////////////////////////////////////// 
chars chars(
    .char(char),
    .rownum(j[2:0]),
    .pixels(pixels)
);
//////////////////////////////////////////////////////////

// always @(posedge newline) begin
//     if (write_char) begin
//         if (count_in_symbol < 3'd7) begin
//             write_char <= 1;
//             count_in_symbol <= count_in_symbol + 3'd1;
//         end else begin
//             count_in_symbol <= 3'd0; 
//             write_char <= 0;
//         end
//     end
// end
//////////////////////////////////////////////////////////
//Блок отображения общего фона и строчек меню
//При желании можно ручным вводом корректировать, принцип хоть и громозкий, зато эффективный

always @(posedge clk) begin
    case(y) 
        y0 + 10: valid = 3'b001;
        y0 + 30: valid = 3'b010;
        y0 + 50: valid = 3'b011;
        y0 + 70: valid = 3'b100;
    default: if (write_char == 0) begin
                valid = 2'b00;
            end
    endcase

    // if ((y >= y0 + 10) && (y < y0 + 18)) begin //Строка, где будет выводится первый набор символов под value == 1
    //     valid <= 2'b01;
    // end else if ((y >= (y0 + 30)) && (y < (y0 + 38))) begin //Строка, где будет выводится второй набор символов под value == 2
    //     valid <= 2'b10;
    // end else begin
    //     valid <= 2'b00;
    // end
end
////////////////////////////////////////////////////////// 
//входной chars, где помещены символы, задействованные в тексте(exit_value - динамически изменяющийся выводимый параметр)
//Здесь мы формируем необходимое нам слово, расставляя символы в нужном поряке
always @(*) begin
    case (valid)
    //mode
    3'b001: begin
                case (x[9:3])
                    x0[9:3] + 7'd1: char = 22;
                    x0[9:3] + 7'd2: char = 24;
                    x0[9:3] + 7'd3: char = 13;
                    x0[9:3] + 7'd4: char = 14;
                    x0[9:3] + 7'd5: char = 37;
                    x0[9:3] + 7'd6: char = 37;
                    x0[9:3] + 7'd7: char = 37;
                    x0[9:3] + 7'd8: char = 37;
                    x0[9:3] + 7'd11: char = input_mode[7:4];
                    x0[9:3] + 7'd12: char = input_mode[3:0];
                default: char = 7'd37;
                endcase
            end
    //TypeAGC
    3'b010: begin
                case (x[9:3])
                    x0[9:3] + 7'd1: char = 29;
                    x0[9:3] + 7'd2: char = 34;
                    x0[9:3] + 7'd3: char = 25;
                    x0[9:3] + 7'd4: char = 14;
                    x0[9:3] + 7'd5: char = 37;
                    x0[9:3] + 7'd6: char = 10;
                    x0[9:3] + 7'd7: char = 16;
                    x0[9:3] + 7'd8: char = 12;
                    x0[9:3] + 7'd11: char = input_Type_AGC[7:4];
                    x0[9:3] + 7'd12: char = input_Type_AGC[3:0];
                    default: char = 7'd37;
                endcase
            end
    //SetLVL1
    3'b011: begin
                case (x[9:3])
                        x0[9:3] + 7'd1: char = 28;
                        x0[9:3] + 7'd2: char = 14;
                        x0[9:3] + 7'd3: char = 29;
                        x0[9:3] + 7'd4: char = 37;
                        x0[9:3] + 7'd5: char = 21;
                        x0[9:3] + 7'd6: char = 31;
                        x0[9:3] + 7'd7: char = 21;
                        x0[9:3] + 7'd8: char = 01;
                        x0[9:3] + 7'd10: char = input_Set_LVL1[19:16];
                        x0[9:3] + 7'd11: char = input_Set_LVL1[15:12];
                        x0[9:3] + 7'd12: char = input_Set_LVL1[11:8];
                        x0[9:3] + 7'd13: char = input_Set_LVL1[7:4];
                        x0[9:3] + 7'd14: char = input_Set_LVL1[3:0];
                        default: char = 7'd37;
                endcase
            end
    //SetLVL2
    3'b100: begin
                case (x[9:3])
                        x0[9:3] + 7'd1: char = 28;
                        x0[9:3] + 7'd2: char = 14;
                        x0[9:3] + 7'd3: char = 29;
                        x0[9:3] + 7'd4: char = 37;
                        x0[9:3] + 7'd5: char = 21;
                        x0[9:3] + 7'd6: char = 31;
                        x0[9:3] + 7'd7: char = 21;
                        x0[9:3] + 7'd8: char = 02;
                        x0[9:3] + 7'd11: char = input_Set_LVL2[15:12];
                        x0[9:3] + 7'd12: char = input_Set_LVL2[11:8];
                        x0[9:3] + 7'd13: char = input_Set_LVL2[7:4];
                        x0[9:3] + 7'd14: char = input_Set_LVL2[3:0];
                        default: char = 7'd37;
                endcase
            end
    endcase
end
//////////////////////////////////////////////////////////
//Полученный массив pixels выводим попиксельно в рамках полученного пакета
always @(posedge clk) begin
    if (window) begin
    //case({window, valid})
        //Задний фон рамки
        // 3'b100: begin
        // out_bit_B <= 0;
        // out_bit_G <= 0;
        // out_bit_R <= 1; 
        //         end 
        //Символы внутри рамки 1
        case (valid)
        3'b001: begin
                    if (pixels[7 - i]) begin
                        out_data_signal <= 8'b00110000;
                    end else begin
                        out_data_signal <= 8'b00000001;
                    end
                end
        //Символы внутри рамки 2
        3'b010: begin
                   if (pixels[7 - i]) begin
                        out_data_signal <= 8'b00000001;
                    end else begin
                        out_data_signal <= 8'b01000000;
                    end
                end
        //Символы внутри рамки 3
        3'b011: begin
                  if (pixels[7 - i]) begin
                        out_data_signal <= 8'b00000010;
                    end else begin
                        out_data_signal <= 8'b01000000;
                    end
                end
        //Символы внутри рамки 4
        3'b100: begin
                    if (pixels[7 - i]) begin
                        out_data_signal <= 8'b00011000;
                    end else begin
                        out_data_signal <= 8'b01000000;
                    end
                end
       // Остальная часть экрана
        3'b000: begin
                   out_data_signal <= 8'b00000000;
                end
     endcase
    end else begin
        out_data_signal <= 8'b00000000; 
    end
    // if (window == 1) begin
    //     out_bit_B <= 1;
    //     out_bit_G <= 0;
    //     out_bit_R <= 0;
    // end else begin
    //     out_bit_B <= 0;
    //     out_bit_G <= 0;
    //     out_bit_R <= 0;
    // end
    // if (valid) begin
    //     if (pixels[7 - x[2:0]]) begin
    //         out_bit_R <= 1;
    //         out_bit_G <= 1;
    //         out_bit_B <= 1;
    //     end else begin
    //         out_bit_R <= 0;
    //         out_bit_G <= 0;
    //         out_bit_B <= 0;
    //     end
    // end
end
//////////////////////////////////////////////////////////
//Этот счетчик нужен для chars.v, так как "y" может привязаться не к началу отрисовки символа
always @(posedge newline) begin
    if (valid) begin
        write_char <= 1;
        if (j < 7) begin
            j <= j + 1;
        end else begin
    //if (j == 7) begin
            j <= 0;
            write_char <= 0;
        end
    end
end
//////////////////////////////////////////////////////////

always @(posedge clk) begin
    if (valid) begin
        i <= i + 1;
    end
    if (i == 7) begin
        i <= 0;
    end
end
endmodule