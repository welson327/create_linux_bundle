class Parameter

    # public enum sampling_mode {
        # SAMPLING_MODE_100,      # data number = 100 (for 649)
        # SAMPLING_MODE_80,       # for 539
        # SAMPLING_MODE_10,       # for 539
        
        # SAMPLING_MODE_N,   
        # SAMPLING_MODE_ALL
    # }

    # public enum rule {
        # RULE_5_OF_10,
        # RULE_4_OF_10,
        # RULE_4_OF_8,
        # RULE_3_OF_8, 

        # RULE_AGGRESSIVE,        # for aggressive, bw=9, pr=9 in 649
        # RULE_5_OF_7,            # 649
        # RULE_4_OF_6             # 539
    # }
    
    #----------------------------------------------
    
    @sampling_peak_num = 0  # ���ˮp�ȼ�
    @sel_region_num = 0     # �D�X�Ӱ϶�
    @band_width = 0         # band width
    @peak_resolution = 0    # �襤�@��peak�ɡA�۾F���X�s�P�]��peak(1,3,5)
    @data_num = 0           # Ū�J���R����Ƽ�

	attr_accessor :sampling_peak_num, :sel_region_num, :band_width, :peak_resolution, :data_num
end
