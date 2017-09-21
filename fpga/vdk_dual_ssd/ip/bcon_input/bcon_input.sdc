# Below are timing ignores to include for the bcon_input component. These are ignores for clock domain crossings and
#  are acceptable because this unit is data driven by the incoming frame data. All of the register values will be setup
#  and settle well before there is incoming frame data.

set_false_path -from {*|bcon_input:*|s_srst_reg*} -to {*|*}
set_false_path -from {*|bcon_input:*|s_bcon_mode_reg*} -to {*|bcon_input:*|s_bcon_mode_reg_m*}
set_false_path -from {*|bcon_input:*|s_roi_col_start_reg*} -to {*|bcon_input:*|s_roi_col_start_reg_m*}
set_false_path -from {*|bcon_input:*|s_roi_col_end_reg*} -to {*|bcon_input:*|s_roi_col_end_reg_m*}
set_false_path -from {*|bcon_input:*|s_roi_row_start_reg*} -to {*|bcon_input:*|s_roi_row_start_reg_m*}
set_false_path -from {*|bcon_input:*|s_roi_row_end_reg*} -to {*|bcon_input:*|s_roi_row_end_reg_m*}
set_false_path -from {*|bcon_input:*|s_ignore_dval_reg*} -to {*|bcon_input:*|s_ignore_dval_reg_m*}
set_false_path -from {*|bcon_input:*|s_num_cols_reg*} -to {*|bcon_input:*|s_num_cols_reg_m*}
set_false_path -from {*|bcon_input:*|s_num_rows_reg*} -to {*|bcon_input:*|s_num_rows_reg_m*}
set_false_path -from {*|bcon_input:*|s_new_frame_tog*} -to {*|bcon_input:*|s_new_frame_tog_m*}
set_false_path -from {*|bcon_input:*|s_xclk_locked_reg*} -to {*|bcon_input:*|s_xclk_locked_reg_m*}
set_false_path -from {*|*} -to {*|bcon_input:*|s_fifo_data_full_reg*}