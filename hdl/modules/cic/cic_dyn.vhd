-------------------------------------------------------------------------------
-- Title      : CIC with dynamically-adjustable decimator
-- Project    :
-------------------------------------------------------------------------------
-- File       : cic.vhd
-- Author     : aylons  <aylons@LNLS190>
-- Company    :
-- Created    : 2014-03-11
-- Last update: 2016-05-02
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: CIC with dinamically adjustable decimation rate
-------------------------------------------------------------------------------
-- Copyright (c) 2014
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2014-03-11  1.0      aylons  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library UNISIM;
use UNISIM.vcomponents.all;

library work;
use work.dsp_cores_pkg.all;

-------------------------------------------------------------------------------

entity cic_dyn is

  generic (
    g_input_width  : natural := 16;
    g_output_width : natural := 16;
    g_stages       : natural := 1;      -- aka "N"
    g_delay        : natural := 1;      -- aka "M"
    g_max_rate     : natural := 2048;   -- Max decimation rate
    g_bus_width    : natural := 11      -- Decimation ratio bus width.
    );
  port (
    clock_i : in  std_logic                                   := '0';
    reset_i : in  std_logic                                   := '0';
    ce_i    : in  std_logic                                   := '0';
    valid_i : in  std_logic                                   := '1';
    data_i  : in  std_logic_vector(g_input_width-1 downto 0)  := (others => '0');
    ratio_i : in  std_logic_vector(g_bus_width-1 downto 0)    := (others => '0');
    data_o  : out std_logic_vector(g_output_width-1 downto 0) := (others => '0');
    valid_o : out std_logic                                   := '0'
    );

end entity cic_dyn;

-------------------------------------------------------------------------------

architecture str of cic_dyn is
  signal decimation_strobe : std_logic := '0';

begin  -- architecture str

  cmp_strobe_gen : strobe_gen
    generic map (
      g_maxrate   => g_max_rate,
      g_bus_width => g_bus_width)
    port map (
      clock_i  => clock_i,
      reset_i  => reset_i,
      ce_i     => ce_i,
      ratio_i  => ratio_i,
      strobe_o => decimation_strobe);

  cmp_cic_decim : cic_decim
    generic map (
      DATAIN_WIDTH  => g_input_width,
      DATAOUT_WIDTH => g_output_width,
      M             => g_delay,
      N             => g_stages,
      MAXRATE       => g_max_rate,
      bitgrowth     => integer(ceil(real(g_stages)*log2(real(g_delay)*real(g_max_rate)))))
    port map (
      clk_i     => clock_i,
      rst_i     => reset_i,
      en_i      => ce_i,
      data_i    => data_i,
      data_o    => data_o,
      act_i     => valid_i,
      act_out_i => decimation_strobe,
      val_o     => valid_o);

end architecture str;

-------------------------------------------------------------------------------
