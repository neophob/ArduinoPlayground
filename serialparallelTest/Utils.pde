//ripped/inspired by https://github.com/hackrockcity/domeFirmware/blob/master/c%2B%2B_host/LedStrip.cpp

//send 64 bytes: 8 bytes for each 8 output streams, one color needs 3 bytes    
void  ConvertColor24(byte r, byte g, byte b) {

/*    output_data[0] = 0xFF;
    output_data[8] = 0xFF;
    output_data[16] = 0xFF;


    for (int bit_index = 7; bit_index > 0; bit_index--) {
        for (int pixel_index = 0; pixel_index < 8; pixel_index++) {
            output_data[1 +7-bit_index] |= ((input_data[1 + 3*pixel_index] >> bit_index) & 1) << pixel_index;
            output_data[9 +7-bit_index] |= ((input_data[    3*pixel_index] >> bit_index) & 1) << pixel_index;
            output_data[17+7-bit_index] |= ((input_data[2 + 3*pixel_index] >> bit_index) & 1) << pixel_index;
        }
    }*/
}

