`timescale 1ns / 1ps

module saat_bolucu_MSB(
    input  logic clk_100mhz,    //ana clk giriþi 
    input  logic reset,
    output logic clk_25mhz  //üretilen yeni clk'un çýkýþý     
);

    logic [1:0] clk_sayac = 2'b00;  //iki bitlik sayaç tanýmladýk, böylece; 00 01 10 11 sayacak -- 100/4 = 25mhz elde edilecek

    always_ff @(posedge clk_100mhz or negedge reset) begin  //ana clk ve resete baðlý çalýþacak
        if (~reset)
            clk_sayac <= 2'b00; //reset aktifse sayacý sýfýrladýk
        else
            clk_sayac <= clk_sayac + 1; //her ana clk darbesinde sayaç 1 arttýrýldý
    end

    // sayacýn en anlamlý biti (en soldaki bit) 4 darbede bir tam turunu tamamlamýþ oluyor
    // 00 01 10 11 olarak saydýðý düþünülürse 0 0 1 1 bir tam turu oluyor sonrasýnda tekrar 0 0 1 1 sayýyor
    // frekansý dörde bölmemiz gerektiði için (100/4=25MHz elde etmeye çalýþýyoruz) bu deðeri yeni clk darbemiz olarak atýyoruz
    assign clk_25mhz = clk_sayac[1];

endmodule