-------------------------------------------------------------------------------
-- Title      : Cordic_iter - Wishbone Stream version
-- Project    : 
-------------------------------------------------------------------------------
-- File       : wbs_cordic_iter.vhd
-- Author     : Vitor Finotti Ferreira  <vfinotti@finotti-Inspiron-7520>
-- Company    : Brazilian Synchrotron Light Laboratory, LNLS/CNPEM
-- Created    : 2015-08-04
-- Last update: 2015-08-06
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Module "cordic_iter" wrapped by and wishbone stream wrapper
-------------------------------------------------------------------------------
-- Copyright (c) 2015 Brazilian Synchrotron Light Laboratory, LNLS/CNPEM    

-- This program is free software: you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public License
-- as published by the Free Software Foundation, either version 3 of
-- the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this program. If not, see
-- <http://www.gnu.org/licenses/>.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2015-08-04  1.0      vfinotti        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.wb_stream_pkg.all;

-------------------------------------------------------------------------------

entity wbs_cordic_iter is

  generic (
    g_input_width   : natural := 32;
    g_output_width  : natural := 32;
    g_tgd_width     : natural := 4;
    g_adr_width     : natural := 4;
    g_input_depth   : natural := 2;
    g_output_depth  : natural := 2;
    g_input_buffer  : natural := 4;
    g_output_buffer : natural := 2;
    g_ce_core       : natural := 5);

  port (
    clk_i : in  std_logic;
    rst_i : in  std_logic;
    ce_i  : in  std_logic;
    snk_i : in  t_wbs_sink_in;
    snk_o : out t_wbs_sink_out;
    src_i : in  t_wbs_source_in;
    src_o : out t_wbs_source_out);
  --dat_o     : out std_logic_vector(g_input_width-1 downto 0);
  --dat_i     : in  std_logic_vector(g_output_width-1 downto 0);
  --busy_i    : in  std_logic;
  --valid_o   : out std_logic;
  --valid_i   : in  std_logic;
  --ce_core_o : out std_logic);

end entity wbs_cordic_iter;

architecture behavior of wbs_cordic_iter is

  -----------------------------------------------------------------------------
  -- Signal declarations
  -----------------------------------------------------------------------------

  -- Global signals
  signal s_clk : std_ulogic := '0';     -- clock signal
  signal s_rst : std_ulogic := '1';     -- reset signal
  signal s_ce  : std_ulogic := '0';     -- clock enable

  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- component generics
  --constant g_input_width   : natural := 32;
  --constant g_output_width  : natural := 32;
  --constant g_tgd_width     : natural := 4;
  --constant g_adr_width     : natural := 4;
  --constant g_input_depth   : natural := 2;
  --constant g_output_depth  : natural := 2;
  --constant g_input_buffer  : natural := 4;
  --constant g_output_buffer : natural := 2;
  --constant g_ce_core       : natural := 5;

  -- component ports
  signal s_snk_i     : t_wbs_sink_in(dat(g_input_depth-1 downto 0)(g_input_width-1 downto 0));
  signal s_snk_o     : t_wbs_sink_out;
  signal s_src_i     : t_wbs_source_in;
  signal s_src_o     : t_wbs_source_out(dat(g_output_depth-1 downto 0)(g_output_width-1 downto 0));
  signal s_dat_o     : array_dat(g_input_depth-1 downto 0)(g_input_width-1 downto 0);
  signal s_dat_i     : array_dat(g_output_depth-1 downto 0)(g_output_width-1 downto 0);
  signal s_busy_i    : std_logic;
  signal s_valid_o   : std_logic;
  signal s_valid_i   : std_logic;
  signal s_ce_core_o : std_logic;

  -- auxiliar signals
  -- signal ce_counter      : natural   := 0;  -- count number of ce events
  -- signal ce_core_counter : natural   := 0;
  -- signal valid_out       : std_logic := '0';

  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------

  constant c_INPUT_WIDTH    : positive := 32;
  constant c_OUTPUT_WIDTH   : positive := 32;
  constant c_INTERNAL_WIDTH : positive := 38;  -- output_width + log2(c_ITER) +
                                               -- 2

  constant c_PHASE_OUTPUT_WIDTH   : positive := 32;  -- width of phase output
  constant c_PHASE_INTERNAL_WIDTH : positive := 34;  -- width of cordic phase

  constant c_ITER         : positive := 16;  -- number of cordic steps
  constant c_ITER_PER_CLK : positive := 2;  -- number of iterations per clock cycle

  constant c_USE_CE    : boolean := true;  -- clock enable in cordic
  constant c_ROUNDING  : boolean := true;  -- enable rounding in cordic
  constant c_USE_INREG : boolean := true;  -- use input register

  signal s_x : signed(c_INPUT_WIDTH-1 downto 0);  -- x from the input
  signal s_y : signed(c_INPUT_WIDTH-1 downto 0);  -- y from the input

  signal s_mag   : signed(c_OUTPUT_WIDTH-1 downto 0);  -- magnitude from X output in
                                                       -- cordic
  signal s_phase : signed(c_PHASE_OUTPUT_WIDTH-1 downto 0);  -- phase from PH output of cordic

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------

  component wb_stream_wrapper is
    generic (
      g_input_width   : natural;
      g_output_width  : natural;
      g_tgd_width     : natural;
      g_adr_width     : natural;
      g_input_depth   : natural;
      g_output_depth  : natural;
      g_input_buffer  : natural;
      g_output_buffer : natural;
      g_ce_core       : natural);
    port (
      clk_i     : in  std_logic;
      rst_i     : in  std_logic;
      ce_i      : in  std_logic;
      snk_i     : in  t_wbs_sink_in;
      snk_o     : out t_wbs_sink_out;
      src_i     : in  t_wbs_source_in;
      src_o     : out t_wbs_source_out;
      dat_o     : out array_dat;
      dat_i     : in  array_dat;
      busy_i    : in  std_logic;
      valid_o   : out std_logic;
      valid_i   : in  std_logic;
      ce_core_o : out std_logic);
  end component wb_stream_wrapper;

  component cordic is
    generic (
      XY_CALC_WID  : positive;
      XY_IN_WID    : positive;
      X_OUT_WID    : positive;
      PH_CALC_WID  : positive;
      PH_OUT_WID   : positive;
      NUM_ITER     : positive;
      ITER_PER_CLK : positive;
      USE_INREG    : boolean;
      USE_CE       : boolean;
      ROUNDING     : boolean);
    port (
      clk        : in  std_logic;
      ce         : in  std_logic;
      b_start_in : in  std_logic;
      s_x_in     : in  signed (XY_IN_WID-1 downto 0);
      s_y_in     : in  signed (XY_IN_WID-1 downto 0);
      s_x_o      : out signed (X_OUT_WID-1 downto 0);
      s_ph_o     : out signed (PH_OUT_WID-1 downto 0);
      b_rdy_o    : out std_logic;
      b_busy_o   : out std_logic);
  end component cordic;

begin  -- architecture behavior

  -----------------------------------------------------------------------------
  -- Processes and Procedures
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Combinational logic and other signal atributions
  -----------------------------------------------------------------------------

  -- Conversion between data types
  s_x <= signed(s_dat_o(0));
  s_y <= signed(s_dat_o(1));

  s_dat_i(0) <= std_logic_vector(s_mag);
  s_dat_i(1) <= std_logic_vector(s_phase);

  -- Conecting ports and signals
  s_clk   <= clk_i;
  s_rst   <= rst_i;
  s_ce    <= ce_i;
  s_snk_i <= snk_i;
  snk_o   <= s_snk_o;
  s_src_i <= src_i;
  src_o   <= s_src_o;


  -----------------------------------------------------------------------------
  -- Port Maps
  -----------------------------------------------------------------------------

  wrapper : wb_stream_wrapper
    generic map (
      g_input_width   => g_input_width,
      g_output_width  => g_output_width,
      g_tgd_width     => g_tgd_width,
      g_adr_width     => g_adr_width,
      g_input_depth   => g_input_depth,
      g_output_depth  => g_output_depth,
      g_input_buffer  => g_input_buffer,
      g_output_buffer => g_output_buffer,
      g_ce_core       => g_ce_core)
    port map (
      clk_i     => s_clk,
      rst_i     => s_rst,
      ce_i      => s_ce,
      snk_i     => s_snk_i,
      snk_o     => s_snk_o,
      src_i     => s_src_i,
      src_o     => s_src_o,
      -- ports connected to core
      dat_o     => s_dat_o,
      dat_i     => s_dat_i,
      busy_i    => s_busy_i,
      valid_o   => s_valid_o,
      valid_i   => s_valid_i,
      ce_core_o => s_ce_core_o);

  cord : cordic
    generic map (
      XY_CALC_WID  => c_INTERNAL_WIDTH,
      XY_IN_WID    => c_INPUT_WIDTH,
      X_OUT_WID    => c_OUTPUT_WIDTH,
      PH_CALC_WID  => c_PHASE_INTERNAL_WIDTH,
      PH_OUT_WID   => c_PHASE_OUTPUT_WIDTH,
      NUM_ITER     => c_ITER,
      ITER_PER_CLK => c_ITER_PER_CLK,
      USE_INREG    => c_USE_INREG,
      USE_CE       => c_USE_CE,
      ROUNDING     => c_ROUNDING)
    port map (
      clk        => s_clk,
      ce         => s_ce_core_o,
      b_start_in => s_valid_o,
      b_busy_o   => s_busy_i,
      s_x_in     => s_x,
      s_y_in     => s_y,
      s_x_o      => s_mag,
      s_ph_o     => s_phase,
      b_rdy_o    => s_valid_i);


end architecture behavior;
