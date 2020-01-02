# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "CONTROL_BUS_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CP0_to_MMU_tlb_config_width" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CPU_D_CACHE_LINE_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CPU_D_NUM_ROADS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CPU_D_TAG_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CPU_I_CACHE_LINE_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CPU_I_NUM_ROADS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CPU_I_TAG_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "Entry_id_width" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MMU_to_CP0_tlb_config_width" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TLB_entry_num" -parent ${Page_0}


}

proc update_PARAM_VALUE.CONTROL_BUS_WIDTH { PARAM_VALUE.CONTROL_BUS_WIDTH } {
	# Procedure called to update CONTROL_BUS_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CONTROL_BUS_WIDTH { PARAM_VALUE.CONTROL_BUS_WIDTH } {
	# Procedure called to validate CONTROL_BUS_WIDTH
	return true
}

proc update_PARAM_VALUE.CP0_to_MMU_tlb_config_width { PARAM_VALUE.CP0_to_MMU_tlb_config_width } {
	# Procedure called to update CP0_to_MMU_tlb_config_width when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CP0_to_MMU_tlb_config_width { PARAM_VALUE.CP0_to_MMU_tlb_config_width } {
	# Procedure called to validate CP0_to_MMU_tlb_config_width
	return true
}

proc update_PARAM_VALUE.CPU_D_CACHE_LINE_WIDTH { PARAM_VALUE.CPU_D_CACHE_LINE_WIDTH } {
	# Procedure called to update CPU_D_CACHE_LINE_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CPU_D_CACHE_LINE_WIDTH { PARAM_VALUE.CPU_D_CACHE_LINE_WIDTH } {
	# Procedure called to validate CPU_D_CACHE_LINE_WIDTH
	return true
}

proc update_PARAM_VALUE.CPU_D_NUM_ROADS { PARAM_VALUE.CPU_D_NUM_ROADS } {
	# Procedure called to update CPU_D_NUM_ROADS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CPU_D_NUM_ROADS { PARAM_VALUE.CPU_D_NUM_ROADS } {
	# Procedure called to validate CPU_D_NUM_ROADS
	return true
}

proc update_PARAM_VALUE.CPU_D_TAG_WIDTH { PARAM_VALUE.CPU_D_TAG_WIDTH } {
	# Procedure called to update CPU_D_TAG_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CPU_D_TAG_WIDTH { PARAM_VALUE.CPU_D_TAG_WIDTH } {
	# Procedure called to validate CPU_D_TAG_WIDTH
	return true
}

proc update_PARAM_VALUE.CPU_I_CACHE_LINE_WIDTH { PARAM_VALUE.CPU_I_CACHE_LINE_WIDTH } {
	# Procedure called to update CPU_I_CACHE_LINE_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CPU_I_CACHE_LINE_WIDTH { PARAM_VALUE.CPU_I_CACHE_LINE_WIDTH } {
	# Procedure called to validate CPU_I_CACHE_LINE_WIDTH
	return true
}

proc update_PARAM_VALUE.CPU_I_NUM_ROADS { PARAM_VALUE.CPU_I_NUM_ROADS } {
	# Procedure called to update CPU_I_NUM_ROADS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CPU_I_NUM_ROADS { PARAM_VALUE.CPU_I_NUM_ROADS } {
	# Procedure called to validate CPU_I_NUM_ROADS
	return true
}

proc update_PARAM_VALUE.CPU_I_TAG_WIDTH { PARAM_VALUE.CPU_I_TAG_WIDTH } {
	# Procedure called to update CPU_I_TAG_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CPU_I_TAG_WIDTH { PARAM_VALUE.CPU_I_TAG_WIDTH } {
	# Procedure called to validate CPU_I_TAG_WIDTH
	return true
}

proc update_PARAM_VALUE.Entry_id_width { PARAM_VALUE.Entry_id_width } {
	# Procedure called to update Entry_id_width when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.Entry_id_width { PARAM_VALUE.Entry_id_width } {
	# Procedure called to validate Entry_id_width
	return true
}

proc update_PARAM_VALUE.MMU_to_CP0_tlb_config_width { PARAM_VALUE.MMU_to_CP0_tlb_config_width } {
	# Procedure called to update MMU_to_CP0_tlb_config_width when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MMU_to_CP0_tlb_config_width { PARAM_VALUE.MMU_to_CP0_tlb_config_width } {
	# Procedure called to validate MMU_to_CP0_tlb_config_width
	return true
}

proc update_PARAM_VALUE.TLB_entry_num { PARAM_VALUE.TLB_entry_num } {
	# Procedure called to update TLB_entry_num when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TLB_entry_num { PARAM_VALUE.TLB_entry_num } {
	# Procedure called to validate TLB_entry_num
	return true
}


proc update_MODELPARAM_VALUE.CONTROL_BUS_WIDTH { MODELPARAM_VALUE.CONTROL_BUS_WIDTH PARAM_VALUE.CONTROL_BUS_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CONTROL_BUS_WIDTH}] ${MODELPARAM_VALUE.CONTROL_BUS_WIDTH}
}

proc update_MODELPARAM_VALUE.CP0_to_MMU_tlb_config_width { MODELPARAM_VALUE.CP0_to_MMU_tlb_config_width PARAM_VALUE.CP0_to_MMU_tlb_config_width } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CP0_to_MMU_tlb_config_width}] ${MODELPARAM_VALUE.CP0_to_MMU_tlb_config_width}
}

proc update_MODELPARAM_VALUE.MMU_to_CP0_tlb_config_width { MODELPARAM_VALUE.MMU_to_CP0_tlb_config_width PARAM_VALUE.MMU_to_CP0_tlb_config_width } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MMU_to_CP0_tlb_config_width}] ${MODELPARAM_VALUE.MMU_to_CP0_tlb_config_width}
}

proc update_MODELPARAM_VALUE.TLB_entry_num { MODELPARAM_VALUE.TLB_entry_num PARAM_VALUE.TLB_entry_num } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TLB_entry_num}] ${MODELPARAM_VALUE.TLB_entry_num}
}

proc update_MODELPARAM_VALUE.Entry_id_width { MODELPARAM_VALUE.Entry_id_width PARAM_VALUE.Entry_id_width } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.Entry_id_width}] ${MODELPARAM_VALUE.Entry_id_width}
}

proc update_MODELPARAM_VALUE.CPU_D_CACHE_LINE_WIDTH { MODELPARAM_VALUE.CPU_D_CACHE_LINE_WIDTH PARAM_VALUE.CPU_D_CACHE_LINE_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CPU_D_CACHE_LINE_WIDTH}] ${MODELPARAM_VALUE.CPU_D_CACHE_LINE_WIDTH}
}

proc update_MODELPARAM_VALUE.CPU_D_TAG_WIDTH { MODELPARAM_VALUE.CPU_D_TAG_WIDTH PARAM_VALUE.CPU_D_TAG_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CPU_D_TAG_WIDTH}] ${MODELPARAM_VALUE.CPU_D_TAG_WIDTH}
}

proc update_MODELPARAM_VALUE.CPU_D_NUM_ROADS { MODELPARAM_VALUE.CPU_D_NUM_ROADS PARAM_VALUE.CPU_D_NUM_ROADS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CPU_D_NUM_ROADS}] ${MODELPARAM_VALUE.CPU_D_NUM_ROADS}
}

proc update_MODELPARAM_VALUE.CPU_I_CACHE_LINE_WIDTH { MODELPARAM_VALUE.CPU_I_CACHE_LINE_WIDTH PARAM_VALUE.CPU_I_CACHE_LINE_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CPU_I_CACHE_LINE_WIDTH}] ${MODELPARAM_VALUE.CPU_I_CACHE_LINE_WIDTH}
}

proc update_MODELPARAM_VALUE.CPU_I_TAG_WIDTH { MODELPARAM_VALUE.CPU_I_TAG_WIDTH PARAM_VALUE.CPU_I_TAG_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CPU_I_TAG_WIDTH}] ${MODELPARAM_VALUE.CPU_I_TAG_WIDTH}
}

proc update_MODELPARAM_VALUE.CPU_I_NUM_ROADS { MODELPARAM_VALUE.CPU_I_NUM_ROADS PARAM_VALUE.CPU_I_NUM_ROADS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CPU_I_NUM_ROADS}] ${MODELPARAM_VALUE.CPU_I_NUM_ROADS}
}

