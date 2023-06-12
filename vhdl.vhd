LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY project_reti_logiche IS
    PORT ( i_clk : IN STD_LOGIC;
           i_rst : IN STD_LOGIC;
           i_start : IN STD_LOGIC;
           i_w : IN STD_LOGIC;
           o_z0 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
           o_z1 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
           o_z2 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
           o_z3 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
           o_done : OUT STD_LOGIC;
           o_mem_addr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
           i_mem_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
           o_mem_we : OUT STD_LOGIC;
           o_mem_en : OUT STD_LOGIC
           );
END project_reti_logiche;

ARCHITECTURE Behavioral OF project_reti_logiche IS
    TYPE state_type IS (
                        READ_CHAN,
                        READ_MEM_ADDR,
                        ASK_MEM,
                        WAIT_MEM,
                        READ_MEM,
                        SET_OUTPUT_CHAN,
                        PUSH_OUTPUT,
                        RESET_OUTPUT
    );
    SIGNAL state : state_type;
    SIGNAL o_out : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
    SIGNAL o_address : STD_LOGIC_VECTOR(15 DOWNTO 0):= "0000000000000000";
    SIGNAL counter : INTEGER := 1;
    SIGNAL o_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL o_z0_effective, o_z1_effective, o_z2_effective , o_z3_effective: STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
BEGIN
PROCESS (i_clk, i_rst)
    BEGIN
        o_mem_we <= '0';
        IF (i_rst = '1') THEN
            o_mem_en <= '0';
            state <= READ_CHAN;
            counter <= 1;
            o_out(1) <= '0';
            o_out(0) <= '0';
            o_address <= "0000000000000000";
            o_data <= "00000000";
            o_z0 <= "00000000";
            o_z1 <= "00000000";
            o_z2 <= "00000000";
            o_z3 <= "00000000";
            o_z0_effective <= "00000000";
            o_z1_effective <= "00000000";
            o_z2_effective <= "00000000";
            o_z3_effective <= "00000000";
            o_done <= '0';
        ELSIF (rising_edge(i_clk)) THEN
            CASE state IS
                WHEN READ_CHAN => 
                    IF (i_start = '1') THEN
                        o_out(counter) <= i_w;
                        IF (counter = 0) THEN
                            counter <= 1;
                            state <= READ_MEM_ADDR;
                        ELSE
                            counter <= 0;
                        END IF;
                    END IF;
                WHEN READ_MEM_ADDR =>
                    IF (i_start = '1') THEN
                        FOR i IN 15 DOWNTO 1 LOOP
                            o_address(i) <= o_address(i - 1);
                        END LOOP;
                        o_address(0) <= i_w;
                    ELSE
                        state <= ASK_MEM;
                        o_mem_addr <= o_address;
                    END IF;
                WHEN ASK_MEM =>
                    o_address <= "0000000000000000";
                    o_mem_en <= '1';
                    state <= WAIT_MEM;
                WHEN WAIT_MEM =>
                    state <= READ_MEM;
                    o_mem_en <= '0';    
                WHEN READ_MEM =>
                    o_data <= i_mem_data;
                    state <= SET_OUTPUT_CHAN;
                WHEN SET_OUTPUT_CHAN =>
                    IF (o_out = "00") THEN 
                        o_z0_effective <= o_data;
                    ELSIF (o_out = "01") THEN 
                        o_z1_effective <= o_data;
                    ELSIF (o_out = "10") THEN 
                        o_z2_effective <= o_data;
                    ELSIF (o_out = "11") THEN 
                        o_z3_effective <= o_data;
                    END IF;
                    state <= PUSH_OUTPUT;
                WHEN PUSH_OUTPUT =>
                    o_z0 <= o_z0_effective;
                    o_z1 <= o_z1_effective;
                    o_z2 <= o_z2_effective;
                    o_z3 <= o_z3_effective;
                    o_done <= '1';
                    state <= RESET_OUTPUT;
                WHEN RESET_OUTPUT =>
                    o_z0 <= "00000000";
                    o_z1 <= "00000000";
                    o_z2 <= "00000000";
                    o_z3 <= "00000000";
                    o_done <= '0';
                state <= READ_CHAN;
            END CASE;
        END IF;
    END PROCESS;
END Behavioral;