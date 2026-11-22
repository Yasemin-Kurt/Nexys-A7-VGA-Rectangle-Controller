`timescale 1ns / 1ps

module vga_rectangle_controller(
    input  logic        clk_100mhz, // Nexys A7 ana clk sinyali (100 MHz)
    input  logic        reset,
    input  logic [11:0] sw,         // 12 adet switch (4-bit Red, 4-bit Green, 4-bit Blue olacak)
    output logic        vga_yatay,      // VGA Yatay Senkronizasyon
    output logic        vga_dikey,      // VGA Dikey Senkronizasyon
    output logic [3:0]  vga_red,      // Kýrmýzý renk çýkýþý (4 bit)
    output logic [3:0]  vga_green,      // Yeþil renk çýkýþý (4 bit)
    output logic [3:0]  vga_blue       // Mavi renk çýkýþý (4 bit)
);

    // Piksel Saati Sinyali -- 25MHz olan oluþturduðumuz sinyal
    logic clk_25mhz;

    // Saat Bölücü Modülünün Baðlanmasý
    saat_bolucu_MSB clk_gen_inst (
        .clk_100mhz(clk_100mhz),
        .reset(reset),
        .clk_25mhz(clk_25mhz)
    );

    // 640x480 @ 60Hz Zamanlama Parametreleri
    localparam H_ACTIVE    = 10'd640;   //yatayda görünen piksel -- 640
    localparam H_FP        = 10'd16;
    localparam H_SYNC      = 10'd96;
    localparam H_BP        = 10'd48;
    localparam H_TOTAL     = 10'd800;   //yataydaki toplam piksel -- 800   (görünen 640)

    localparam V_ACTIVE    = 10'd480;   //dikeyde görünen piksel -- 480
    localparam V_FP        = 10'd10;
    localparam V_SYNC      = 10'd2;
    localparam V_BP        = 10'd33;
    localparam V_TOTAL     = 10'd525;   //dikeyde toplam piksel -- 525  (görünen 480)

    // Yatay ve Dikey Sayaçlar
    logic [9:0] h_sayac = 0;
    logic [9:0] v_sayac = 0;  

    // Yatay Sayaç
    always_ff @(posedge clk_25mhz or negedge reset) begin
        if (~reset) begin
            h_sayac <= 0;
        end else begin
            if (h_sayac == H_TOTAL - 1) //sayaç deðeri 799 ise  (sayaç 0-799 sayýyor; bu sebeple 799)
                h_sayac <= 0;   //sayaç sýfýrlanýr
            else
                h_sayac <= h_sayac + 1; //sayaç maksimum deðerine(799) ulaþmamýþsa her darbede 1 arttýrýlýyor
        end
    end

    // Dikey Sayaç
    always_ff @(posedge clk_25mhz or negedge reset) begin
        if (~reset) begin
            v_sayac <= 0;
        end else begin
            if (h_sayac == H_TOTAL - 1) begin   //yatay sayaç deðeri 799 olduðunda
                if (v_sayac == V_TOTAL - 1)     //dikey sayaç deðeri 524 (dikeydeki piksel sayýsý 525'di 0-524 sayýyor) ise
                    v_sayac <= 0;               //dikey sayacý sýfýrla
                else
                    v_sayac <= v_sayac + 1;     //dikey sayaç deðeri 524'e ulaþmamýþsa her darbede 1 arttýrýlýyor
            end
        end
    end
    // yatay sayaç 1 turunu tamamladýðýnda dikey sayma iþlemi yapýlýyor böylece dikey sayaç alt satýra geçildiðini anlamýþ oluyor
    //bu sebepten ötürü kodda 799 olduðunda diyoruz -- 1 yatay tur tamamlanmýþ olduðunda iþleme gir demek
    //farklý always bloklarýnda tanýmlanmalarý da eþ zamanlý çalýþmalaýrný saðlayabilmek için
    

    // vga_yatay ve vga_dikey Sinyallerinin Üretilmesi (Aktif Düþük)
    always_ff @(posedge clk_25mhz or negedge reset) begin
        if (~reset) begin
            vga_yatay <= 1'b1;
            vga_dikey <= 1'b1;
        end else begin
            vga_yatay <= ~((h_sayac >= (H_ACTIVE + H_FP)) && (h_sayac < (H_ACTIVE + H_FP + H_SYNC)));
            vga_dikey <= ~((v_sayac >= (V_ACTIVE + V_FP)) && (v_sayac < (V_ACTIVE + V_FP + V_SYNC)));
        end
    end

    // Aktif Video Bölgesi Kontrolü -- sadece görünür bölge (640*480 içerisini tanýmlar -- burada görüntü oluþturulabilir)
    logic video_on;
    assign video_on = (h_sayac < H_ACTIVE) && (v_sayac < V_ACTIVE);

    // Ekranýn ortasýnda tanýmlanan dikdörtgen bölge
    //yatayda 170-470 ve dikeyde 140-340 arasý piksel bölgeyi seçtik
    logic rectangle_region;
    assign rectangle_region = (h_sayac >= 170) && (h_sayac < 470) && (v_sayac >= 140) && (v_sayac < 340);

    // Renk Çýkýþlarý
    always_comb begin
        if (video_on && rectangle_region) begin
            vga_red = sw[11:8]; 
            vga_green = sw[7:4];  
            vga_blue = sw[3:0];  
        end else begin
            vga_red = 4'h0;
            vga_green = 4'h0;
            vga_blue = 4'h0;
        end
    end

endmodule