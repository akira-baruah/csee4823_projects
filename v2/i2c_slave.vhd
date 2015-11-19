LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY i2c_slave IS
  PORT(clk_hi, SCL_in, SDA_in, byte_done, addr_match_bs   :IN  STD_LOGIC;
       SDA_out, SDA_en, data_out, addr_out, nack_sent :OUT STD_LOGIC);
END i2c_slave;

ARCHITECTURE beh OF i2c_slave IS
  TYPE state_t IS (SL0, SL1, SL2, SA0, SA1, SA2,
    SR0, SR1, SR2, SR3, SR4, SRA0, SRA1, SRA2, SRS0, SRS1, SRS2,
    SW0, SW1, SW2, SWA0, SWA1);
  signal state: state_t := SL0;
BEGIN
  PROCESS (clk_hi)
  BEGIN
    IF (clk_hi'EVENT AND clk_hi = '1') THEN
    CASE state IS
      -- 'Setup' portion
      WHEN SL0 =>
        IF (SDA_in = '1' AND SCL_in = '1') THEN
          state <= SL1;
        ELSE
          state <= SL0;
        END IF;
      WHEN SL1 =>
        IF (SDA_in = '1' AND SCL_in = '1') THEN
          state <= SL1;
        ELSIF (SDA_in = '0' AND SCL_in = '1') THEN
          state <= SL2;
        ELSIF (SCL_in = '0') THEN
          state <= SL0;
        ELSE
          assert false report "unexpected state" severity FAILURE;
        END IF;
      WHEN SL2 =>
        IF (SCL_in = '0') THEN
          state <= SA0;
        ELSIF (SCL_in = '1') THEN
          state <= SL2;
        END IF;
      WHEN SA0 =>
        IF (SCL_in = '0') THEN
          state <= SA0;
        ELSIF (SDA_in = '0' AND SCL_in = '1') THEN
          state <= SA1;
        ELSIF (SDA_in = '1' AND SCL_in = '1') THEN
          state <= SA2;
        ELSE
          assert false report "unexpected state" severity FAILURE;
        END IF;
      WHEN SA1 =>
        IF (SDA_in = '0' AND SCL_in = '1') THEN
          state <= SA1;
        ELSIF (SCL_in = '0' AND addr_match_bs = '1') THEN
          assert (byte_done = '1') report "byte_done not high" severity ERROR;
          state <= SWA0;
        ELSIF (SCL_in = '0' AND addr_match_bs = '0' AND byte_done = '0') THEN
          state <= SA0;
        ELSIF (SCL_in = '0' AND addr_match_bs = '0' AND byte_done = '1') THEN
          state <= SL0;
        ELSE
          assert false report "unexpected state" severity FAILURE;
        END IF;
      WHEN SA2 =>
        IF (SDA_in = '1' AND SCL_in = '1') THEN
          state <= SA2;
        ELSIF (SCL_in = '0' AND addr_match_bs = '1') THEN
          assert byte_done = '1' report "byte_done not high" severity ERROR;
          state <= SRA0;
        ELSIF (SCL_in = '0' AND addr_match_bs = '0' AND byte_done = '0') THEN
          state <= SA0;
        ELSIF (SCL_in = '0' AND addr_match_bs = '0' AND byte_done = '1') THEN
          state <= SL0;
        ELSE
          assert false report "unexpected state" severity FAILURE;
        END IF;

      -- 'write' portion
      when SW0 =>
        if SCL_in = '0' then
          state <= SW0;
        elsif SDA_in = '0' and SCL_in = '1' then
          state <= SW1;
        elsif SDA_in = '1' and SCL_in = '1' then
          state <= SW2;
        else
          assert false report "unexpected state" severity ERROR;
        end if;
      when SW1 =>
        if SCL_in = '1' AND SDA_in = '0' THEN
          state <= SW1;
        elsif SCL_in = '1' AND SDA_in = '1' THEN
          state <= SL0;
        elsif SCL_in = '0' AND byte_done = '1' THEN
          state <= SWA0;
        elsif SCL_in = '0' AND byte_done = '0' THEN
          state <= SW0;
        else
          assert false report "unexpected state" severity ERROR;
        end if;
      when SW2 =>
        if SCL_in = '1' AND SDA_in = '1' THEN
          state <= SW2;
        elsif SCL_in = '0' AND byte_done = '1' THEN
          state <= SWA0;
        elsif SCL_in = '0' AND byte_done = '0' THEN
          state <= SW0;
        else
          assert false report "unexpected state" severity ERROR;
        end if;
      when SWA0 =>
        if SCL_in = '0' then
          state <= SWA0;
        elsif SCL_in = '1' then
          state <= SWA1;
        else
          assert false report "unexpected state" severity ERROR;
        end if;
      when SWA1 =>
        if SCL_in = '0' then
          state <= SW0;
        elsif SCL_in = '1' then
          state <= SWA1;
        else
          assert false report "unexpected state" severity ERROR;
        end if;

      -- 'read' portion
      when SR0 =>
        if SCL_in = '0' and addr_match_bs = '0' then
          state <= SR1;
        elsif SCL_in = '0' and addr_match_bs = '1' then
          state <= SR2;
        else
          assert false report "unexpected state" severity ERROR;
        end if;
      when SR1 =>
        if SCL_in = '0' then
          state <= SR1;
        elsif SCL_in = '1' then
          state <= SR3;
        else
          assert false report "unexpected state" severity ERROR;
        end if;
      when SR2 =>
        if SCL_in = '0' then
          state <= SR2;
        elsif SCL_in = '1' then
          state <= SR4;
        else
          assert false report "unexpected state" severity ERROR;
        end if;
      when SR3 =>
        if SCL_in = '1' then
          state <= SR3;
        elsif SCL_in = '0' and byte_done = '0' then
          state <= SR0;
        elsif SCL_in = '0' and byte_done = '1' then
          state <= SRA0;
        else
          assert false report "unexpected state" severity ERROR;
        end if;
      when SR4 =>
        if SCL_in = '1' then
          state <= SR4;
        elsif SCL_in = '0' and byte_done = '0' then
          state <= SR0;
        elsif SCL_in = '0' and byte_done = '1' then
          state <= SRA0;
        else
          assert false report "unexpected state" severity ERROR;
        end if;
      when SRA0 =>
        if SDA_in = '0' and SCL_in = '0' then
          state <= SRA0;
        elsif SDA_in = '0' and SCL_in = '1' then
          state <= SRA1;
        elsif SDA_in = '1' and SCL_in = '1' then
          state <= SRA2;
        else
          assert false report "unexpected state" severity ERROR;
        end if;
      when SRA1 =>
        if SCL_in = '0' then
          state <= SR0;
        elsif SDA_in = '0' and SCL_in = '1' then
          state <= SRA1;
        else
          assert false report "unexpected state" severity ERROR;
        end if;
      when SRA2 =>
        if SDA_in = '1' and SCL_in = '1' then
          state <= SRA2;
        elsif SCL_in = '0' then
          state <= SRS0;
        else
          assert false report "unexpected state" severity ERROR;
        end if;
      when SRS0 =>
        if SCL_in = '0' then
          state <= SRS0;
        elsif SDA_in = '0' and SCL_in = '1' then
          state <= SRS1;
        else
          assert false report "unexpected state" severity ERROR;
        end if;
      when SRS1 =>
        if SDA_in = '0' and SCL_in = '1' then
          state <= SRS1;
        elsif SDA_in = '1' and SCL_in = '1' then
          state <= SL0;
        end if;
      when SRS2 =>
        if SDA_in = '1' and SCL_in = '1' then
          state <= SRS2;
        elsif SDA_in = '0' and SCL_in = '1' then
          state <= SL2;
        end if;
    END CASE;
    END IF;
  END PROCESS;

  output: PROCESS (state)
  BEGIN
    -- explicitly set to don't care
    -- other signals are set every time
    data_out <= 'X';
    addr_out <= 'X';
    SDA_out <= 'X';
    CASE state IS
      -- listening / addr states
      WHEN SL0 =>
        SDA_en <= '0';
        nack_sent <= '0';
      WHEN SL1 =>
        SDA_en <= '0';
        nack_sent <= '0';
      WHEN SL2 =>
        SDA_en <= '0';
        nack_sent <= '0';
      WHEN SA0 =>
        SDA_en <= '0';
        nack_sent <= '0';
      WHEN SA1 =>
        SDA_en <= '0';
        nack_sent <= '0';
        addr_out <= '0';
      WHEN SA2 =>
        SDA_en <= '0';
        nack_sent <= '0';
        addr_out <= '1';

      --write states
      WHEN SW0 =>
        SDA_en <= '0';
        nack_sent <= '0';
      WHEN SW1 =>
        SDA_en <= '0';
        nack_sent <= '0';
        data_out <= '0';
      WHEN SW2 =>
        SDA_en <= '0';
        nack_sent <= '0';
        data_out <= '1';
      WHEN SWA0 =>
        SDA_en <= '1';
        nack_sent <= '0';
        SDA_out <= '0';
      WHEN SWA1 =>
        SDA_en <= '1';
        nack_sent <= '0';
        SDA_out <= '0';

      -- read states
      WHEN SR0 =>
        SDA_en <= '0';
        nack_sent <= '0';
      WHEN SR1 =>
        SDA_en <= '1';
        nack_sent <= '0';
        SDA_out <= '0';
      WHEN SR2 =>
        SDA_en <= '1';
        nack_sent <= '0';
        SDA_out <= '1';
      WHEN SR3 =>
        SDA_en <= '1';
        nack_sent <= '0';
        SDA_out <= '0';
      WHEN SR4 =>
        SDA_en <= '1';
        nack_sent <= '0';
        SDA_out <= '1';
      WHEN SRA0 =>
        SDA_en <= '0';
        nack_sent <= '0';
      WHEN SRA1 =>
        SDA_en <= '0';
        nack_sent <= '0';
      WHEN SRA2 =>
        SDA_en <= '0';
        nack_sent <= '0';
      WHEN SRS0 =>
        SDA_en <= '0';
        nack_sent <= '0';
      WHEN SRS1 =>
        SDA_en <= '0';
        nack_sent <= '0';
      WHEN SRS2 =>
        SDA_en <= '0';
        nack_sent <= '0';
    END CASE;
  END PROCESS; --output
END beh;
