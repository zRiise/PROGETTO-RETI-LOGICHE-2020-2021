----------------------------------------------------------------------------------
-- Davide Osimo CodicePersona
-- Prof. Fabio Salice
--
-- Module Name: project_reti_logiche - Behavioral
-- Project Name: CodicePersona.vhd
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        o_done : out std_logic;
        o_en : out std_logic;
        o_we : out std_logic;
        o_data : out std_logic_vector (7 downto 0)
    );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
    type state_type is (START, ADDRESS, CHECK, RAM, SCROLL, EQUALIZE, WRITE, DONE_UP, WAIT_START, DONE);
    signal state_next, state_curr: state_type;
    signal o_done_next, o_en_next, o_we_next : std_logic;
	signal o_data_next : std_logic_vector(7 downto 0);
	signal o_address_next : std_logic_vector(15 downto 0);
	signal check_col_curr, check_row_curr, check_col_next, check_row_next, check_dim_curr, check_dim_next, dimtopixel_curr, dimtopixel_next, scrolled_ram_curr, scrolled_ram_next : boolean;
    signal pixel_curr, pixel_next, pixel_max_curr, pixel_max_next, delta_value_curr, delta_value_next, new_pixel_curr, new_pixel_next : integer range 0 to 255;
	signal n_byte_curr, n_byte_next, check_address_curr, check_address_next : integer range 0 to 16384;
	signal address_curr, address_next, new_address_curr, new_address_next : std_logic_vector(15 downto 0);
	signal pixel_min_curr, pixel_min_next : integer range 0 to 255;
	signal dim_col_curr, dim_col_next, dim_row_curr, dim_row_next : integer range 0 to 128;
	signal shift_level_curr, shift_level_next : integer range 0 to 8;
    signal temp_pixel_curr, temp_pixel_next : integer range 0 to 65280;
    signal cont_curr, cont_next : std_logic_vector(1 downto 0);
    signal begin_equalize_curr, begin_equalize_next : boolean;
    
	
begin
    process(i_clk, i_rst)
    begin
        if (i_rst = '1') then
            check_col_curr <= false;
            check_row_curr <= false;
            check_dim_curr <= false;
            dim_col_curr <= 0;
            dim_row_curr <= 0;
            n_byte_curr <= 0;
            address_curr <= "0000000000000010";
            dimtopixel_curr <= false;
            pixel_curr <= 0;
            pixel_max_curr <= 0;
            pixel_min_curr <= 255;
            scrolled_ram_curr <= false;
            check_address_curr <= 0;
            delta_value_curr <= 0;
            temp_pixel_curr <= 0;
            new_pixel_curr <= 0;
            cont_curr <= "00";
            new_address_curr <= "0000000000000010";
            begin_equalize_curr <= true;
            shift_level_curr <= 0;
            state_curr <= START;
            
        elsif rising_edge(i_clk) then
        
            o_done <= o_done_next;
            o_en <= o_en_next;
            o_we <= o_we_next;
            o_data <= o_data_next;
            o_address <= o_address_next;
            
            check_col_curr <= check_col_next;
            check_row_curr <= check_row_next;
            check_dim_curr <= check_dim_next;
            dim_col_curr <= dim_col_next;
            dim_row_curr <= dim_row_next;
            n_byte_curr <= n_byte_next;
            address_curr <= address_next;
            dimtopixel_curr <= dimtopixel_next;
            pixel_curr <= pixel_next;
            pixel_max_curr <= pixel_max_next;
            pixel_min_curr <= pixel_min_next;
            scrolled_ram_curr <= scrolled_ram_next;
            check_address_curr <= check_address_next;
            delta_value_curr <= delta_value_next;
            temp_pixel_curr <= temp_pixel_next;
            new_pixel_curr <= new_pixel_next;
            cont_curr <= cont_next;
            new_address_curr <= new_address_next;
            begin_equalize_curr <= begin_equalize_next;
            shift_level_curr <= shift_level_next;
            state_curr <= state_next;
            
            
        end if;
    end process;
    
    process(i_data, i_start, check_col_curr, check_row_curr, check_dim_curr, dim_col_curr, dim_row_curr, n_byte_curr, address_curr, dimtopixel_curr, pixel_curr, pixel_max_curr, pixel_min_curr, scrolled_ram_curr, check_address_curr, delta_value_curr, temp_pixel_curr, new_pixel_curr, cont_curr, new_address_curr, begin_equalize_curr, shift_level_curr, state_curr)
    begin
        o_done_next <= '0';
        o_en_next <= '0';
        o_we_next <= '0';
        o_data_next <= "00000000";
        o_address_next <= "0000000000000000";
        
        check_col_next <= check_col_curr;
        check_row_next <= check_row_curr;
        check_dim_next <= check_dim_curr;
        dim_col_next <= dim_col_curr;
        dim_row_next <= dim_row_curr;
        n_byte_next <= n_byte_curr;
        address_next <= address_curr;
        dimtopixel_next <= dimtopixel_curr;
        pixel_next <= pixel_curr;
        pixel_max_next <= pixel_max_curr;
        pixel_min_next <= pixel_min_curr;
        scrolled_ram_next <= scrolled_ram_curr;
        check_address_next <= check_address_curr;
        delta_value_next <= delta_value_curr;
        temp_pixel_next <= temp_pixel_curr;
        new_pixel_next <= new_pixel_curr;
        cont_next <= cont_curr;
        new_address_next <= new_address_curr;
        begin_equalize_next <= begin_equalize_curr;
        shift_level_next <= shift_level_curr;
        state_next <= state_curr;
        
        case state_curr is
            when START =>
                if (i_start = '1') then
                    state_next <= ADDRESS;
                end if;
            
            when ADDRESS =>
                o_en_next <= '1';
                o_we_next <= '0';
                
                if (not check_dim_curr) then        
                    if (not check_col_curr) then
                        o_address_next <= "0000000000000000";
                    elsif (not check_row_curr) then
                        o_address_next <= "0000000000000001";
                    end if;
                else
                    o_address_next <= address_curr;
                end if;
                
                state_next <= CHECK;

                
            when CHECK =>
                if (check_col_curr) and (check_row_curr) and (not dimtopixel_curr) then
                    check_dim_next <= true;
                    n_byte_next <= dim_col_curr*dim_row_curr;
                    dimtopixel_next <= true;
                    state_next <= ADDRESS;
                else
                    state_next <= RAM;
                end if;
            
            when RAM =>
                if (not check_dim_curr) then
                    if (not check_col_curr) then
                        if (i_data = "00000000") then
                            state_next <= DONE_UP;
                        else
                            dim_col_next <= to_integer(unsigned(i_data));
                            check_col_next <= true;
                            state_next <= ADDRESS;
                        end if;
                    elsif (not check_row_curr) then
                        if (i_data = "00000000") then
                            state_next <= DONE_UP;
                        else
                            dim_row_next <= to_integer(unsigned(i_data));
                            check_row_next <= true;
                            state_next <= ADDRESS;
                        end if;
                    end if;
                else
                    pixel_next <= to_integer(unsigned(i_data));
                    check_address_next <= to_integer(unsigned(address_curr));
                    if (not scrolled_ram_curr) then
                        state_next <= SCROLL;
                    else
                        state_next <= EQUALIZE;
                    end if;
                end if;
            
            when SCROLL =>
                if (pixel_curr >= pixel_max_curr) then
                    pixel_max_next <= pixel_curr;
                end if;
                
                if (pixel_curr <= pixel_min_curr) then
                    pixel_min_next <= pixel_curr;
                end if;
                
                if (check_address_curr = (n_byte_curr + 1)) then
                    scrolled_ram_next <= true;
                    address_next <= "0000000000000010";
                else
                    address_next <= address_curr + "0000000000000001";
                end if;
                
                state_next <= ADDRESS;
            
            when EQUALIZE =>
                if (cont_curr = "11") then
                    if (temp_pixel_curr >=255) then
                        new_pixel_next <= 255;
                    else
                        new_pixel_next <= temp_pixel_curr;
                    end if;
                    if (begin_equalize_curr) then
                        new_address_next <= std_logic_vector(to_unsigned(n_byte_curr+2, 16));
                        begin_equalize_next <= false;
                    else
                        new_address_next <= new_address_curr + "0000000000000001";
                    end if;
                    
                    cont_next <= "00";
                    state_next <= WRITE;
                       
                elsif (cont_curr = "10") then
                    temp_pixel_next <= (pixel_curr - pixel_min_curr)*(2**shift_level_curr);
                    cont_next <= "11";
                    state_next <= EQUALIZE;
                
                elsif (cont_curr = "01") then
                    if (delta_value_curr = 255) then
                        shift_level_next <= 0;
                    elsif (delta_value_curr > 126) then
                        shift_level_next <= 1;
                    elsif (delta_value_curr > 62) then
                        shift_level_next <= 2;
                    elsif (delta_value_curr > 30) then
                        shift_level_next <= 3;
                    elsif (delta_value_curr > 14) then
                        shift_level_next <= 4;
                    elsif (delta_value_curr > 6) then
                        shift_level_next <= 5;
                    elsif (delta_value_curr > 2) then
                        shift_level_next <= 6;
                    elsif (delta_value_curr > 0) then
                        shift_level_next <= 7;
                    elsif (delta_value_curr = 0) then
                        shift_level_next <= 8;
                    end if;
                    cont_next <= "10";
                    state_next <= EQUALIZE;
                        
                elsif (cont_curr = "00") then
                    delta_value_next <= pixel_max_curr - pixel_min_curr;
                    cont_next <= "01";
                    state_next <= EQUALIZE;
                end if;
            
            when WRITE =>
                o_en_next <= '1';
                o_we_next <= '1';
                o_address_next <= new_address_curr;
                o_data_next <= std_logic_vector(to_unsigned(new_pixel_curr, 8));
                if (check_address_curr = (n_byte_curr + 1)) then
                    state_next <= DONE_UP;
                else
                    address_next <= address_curr + "0000000000000001";
                    state_next <= ADDRESS;
                end if;
            
            when DONE_UP =>
                o_done_next <= '1';
                state_next <= WAIT_START;
            
            when WAIT_START =>
                o_done_next <= '1';
                state_next <= DONE;
            
            when DONE =>
                if (i_start = '0') then
                    check_col_next <= false;
                    check_row_next <= false;
                    check_dim_next <= false;
                    dim_col_next <= 0;
                    dim_row_next <= 0;
                    n_byte_next <= 0;
                    address_next <= "0000000000000010";
                    dimtopixel_next <= false;
                    pixel_next <= 0;
                    pixel_max_next <= 0;
                    pixel_min_next <= 255;
                    scrolled_ram_next <= false;
                    check_address_next <= 0;
                    delta_value_next <= 0;
                    temp_pixel_next <= 0;
                    new_pixel_next <= 0;
                    cont_next <= "00";
                    new_address_next <= "0000000000000010";
                    begin_equalize_next <= true;
                    shift_level_next <= 0;
                    state_next <= START;
                end if;     
        end case;
    end process;
    
end Behavioral;
