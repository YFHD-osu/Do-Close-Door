#include <U8g2lib.h>
#ifdef U8X8_HAVE_HW_SPI
#include <SPI.h>
#endif
#ifdef U8X8_HAVE_HW_I2C
#include <Wire.h>
#endif

U8G2_SSD1306_128X64_NONAME_F_HW_I2C u8g2(U8G2_R0, /* reset=*/ U8X8_PIN_NONE);

class SSD1306 {
  public:
    void begin();
    void println(String context);
    void sendBuffer();
    void clearBuffer();
    
  private:
    int yPos = 14;
};

void SSD1306::begin() {
  u8g2.begin();
  u8g2.enableUTF8Print();  // 啟動 UTF8 支援
  return;
}

void SSD1306::println (String context) {
  u8g2.setFont(u8g2_font_unifont_t_chinese1); // 使用 chinese1字型檔
  u8g2.setCursor(0, yPos); //自動換行
  u8g2.print(context);
  yPos += 16;
  return;
}

void SSD1306::sendBuffer () {  //顯示暫存器內容
  u8g2.sendBuffer();
  return;
}

void SSD1306::clearBuffer () { //清除暫存器內容
  yPos = 14;
  u8g2.clearBuffer();
  return;
}
