import socket, time

class TCPIP:

    def __init__(self, address, port, obj):
        """
            Connect device with tcp ip and check connection
            :param: Address: ip address
            :param: port: port number
        """
        self.address = address
        self.port = port
        self.obj =obj
        try:
            self.socktcp = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            print("Socket successfully created")
        except socket.error as err:
            print("socket creation failed with error %s" % (err))
            exit(1)

    def close_port(self):
        """
            Close connection
        """
        self.socktcp.close()

    def open_port(self):
        """
            open connection
        """
        self.socktcp.connect((self.address, self.port))
        print("Socket successfully connect.")
    def write_port(self, cmd):
        """
            Send data to the device through tcpip connection
            :param cmd: commend to send
            :return:
        """
        try:
            print(f'{self.obj}: cmd: {cmd}')
            self.socktcp.send((cmd + '\n').encode())

        except socket.error as e:
            print("socket sending failed with error %s" % (e))
            exit(-1)

    def read_port(self, cmd):
        """
            Read data from the device through tcpip connection
            :return:
        """
        try:
            buffer_size = 1024
            self.write_port(cmd)
            recived_buffer = self.socktcp.recv(buffer_size).decode()
            print(f"{self.obj}: recv: {recived_buffer}")

        except socket.error as e:
            print("socket reciving failed with error %s" % (e))
            exit(1)
        return recived_buffer


class N6701A:

    def __init__(self, address, port, obj):
        self.interface = "TCPip"
        self.address = address
        self.port = port
        self.idn = "*IDN?"
        self.device = TCPIP(self.address, self.port, obj)
        self.device.socktcp.settimeout(5)

    # ************************************************************************************ #
    # ******************************* Measure Commands  ************************************ #
    # ************************************************************************************ #

    def get_voltage(self, channel=1):
        """
            These query perform a measurement and return the DC output
            voltage in volts
            :channel: integer. Desire channel
        """
        self.cmd = f"MEASure:VOLTage:DC? (@{channel})"
        return self.device.read_port(self.cmd)

    def get_current(self, channel=1):
        """
            These query perform a measurement and return the DC output
            current in amperes.
            :channel: integer. Desire channel
        """
        self.cmd = f"MEASure:CURRent:DC? (@{channel})"
        return self.device.read_port(self.cmd)

    # ************************************************************************************ #
    # ******************************* Output Commands ************************************ #
    # ************************************************************************************ #

    def set_output(self, state, channel=1):
        """
            This command enables or disables the specified output
            On = 1, Off = 0
            :channel: integer. Desire channel
        """
        mode = {'OFF': 0, 'ON': 1}
        self.cmd = f"OUTPut {mode[state]}, (@{channel})"
        return self.device.write_port(self.cmd)

    def get_output(self, channel=1):
        """
            The query returns 0 if the output is off,
            and 1 if the output is on. The *RST value = Off.
            :channel: integer. Desire channel
        """
        self.cmd = f"OUTPut? (@{channel})"
        return self.device.read_port(self.cmd)

    # ************************************************************************************ #
    # ******************************* Common Commands ************************************ #
    # ************************************************************************************ #

    def closePort(self):
        """
        Close serial port
        :return:
        """
        self.device.close_port()

    def openPort(self):
        """
        Close serial port
        :return:
        """
        self.device.open_port()

    def get_idn(self):
        """
            This query requests the power supply to identify itself. It returns a
            string of four fields separated by commas.
            Agilent Technologies    Manufacturer
            xxxxxA                  Model number followed by a letter suffix
            0                       Zero or serial number if available
            <A.xx.xx>,<A.xx.xx>     Firmware revision, power supply revision
        """
        self.cmd = f"*IDN?"
        return self.device.read_port(self.cmd)

    def reset(self):
        """
            This command resets the power supply to a factory-defined state.
            This state is defined as follows. Note that *RST also forces an ABORt
            command. The *RST settings are as follows:
            CAL:STAT    Off     [SOUR:]CURR:PROT:STAT   Off
            INIT:CONT   Off     [SOUR:]VOLT              0
            OUTP        Off     [SOUR:]VOLT:LIM          0
            [SOUR:]CURR  0      [SOUR:]VOLT:TRIG         0
            [SOUR:]CURR:TRIG 0  [SOUR:]VOLT:PROT        MAXimum
        """
        self.cmd = f"*RST"
        return self.device.write_port(self.cmd)

    def save(self, value=0):
        """
            This command stores the present state of the power supply to
            memory locations 0 through 15
            :param value: memory address: 0 to 15
            !!All saved instrument states are lost when the unit is turned off!!
        """
        self.cmd = f"*SAV{value}"
        return self.device.write_port(self.cmd)

    def recall(self, value=0):
        """
            This command restores the power supply to a state that was
            previously stored in memory locations 0 through 15 with the *SAV
            command. Note that you can only recall a state from a location that
            contains a previously-stored state.
        """
        self.cmd = f"*RCL{value}"
        return self.device.write_port(self.cmd)

    def self_test(self):
        """
            This query always returns a zero.
        """
        self.cmd = f"*TST?"
        return self.device.read_port(self.cmd)

    def wait(self):
        """
            This command instructs the power supply not to process any further
            commands until all pending operations are completed. Pending
            operations are as defined under the *OPC command. *WAI can be
            aborted only by sending the power supply a Device Clear command.
        """
        self.cmd = f"*WAI"
        return self.device.write_port(self.cmd)

    def status_byte(self):
        """
            This query reads the Status Byte register, which contains the status
            summary bits and the Output Queue MAV bit. Reading the Status
            Byte register does not clear it. The input summary bits are cleared
            when the appropriate event registers are read. The MAV bit is cleared
            at power-on, by *CLS' or when there is no more response data
            available.
            A serial poll also returns the value of the Status Byte register, except
            that bit 6 returns Request for Service (RQS) instead of Master Status
            Summary (MSS). A serial poll clears RQS, but not MSS. When MSS is
            set, it indicates that the power supply has one or more reasons for
            requesting service.

            Bit Position        7       6       5       4       3      2   1 − 0

            Bit Value           128     64      32      16      8      4     −
            Bit Name            OPER    MSS     ESB     MAV     QUES   ERR   −
                                        (RQS)

            OPER = Operation status summary
            MSS = Master status summary
            (RQS) = Request for service
            ESB = Event status byte summary
            MAV = Message available
            QUES = Questionable status summary
            ERR = Error queue not empt
        """
        self.cmd = f"*STB?"
        return self.device.read_port(self.cmd)

    # ************************************************************************************ #
    # ******************************* System Commands ************************************ #
    # ************************************************************************************ #

    def get_scpi_version(self):
        """
        This query returns the SCPI version number to which the electronic load complies.
        :return: The value is of the form YYYY.V, where YYYY is the year and V is the revision number for that year.
        """
        self.cmd = f"SYSTem:VERSion?"
        return self.device.read_port(self.cmd)

    def get_control_connection_port(self):
        """
            This query returns the control connection port number. This is used
            to open a control socket connection to the instrument.
        """
        self.cmd = f"SYSTem:COMMunicate:TCPip:CONTrol?"
        return self.device.read_port(self.cmd)

    def set_communicate_mode(self, mode):
        """
            This command configures the mode state of the instrument
            according to the following settings.
            LOCal: The instrument is set to front panel control (front panel keys are active).
            REMote: The instrument is set to remote interface control (front panel keys are active).
            RWLock: The front panel keys are disabled (the instrument can only be controlled via the
            remote interface).
            The remote/local state can also be set by interface commands over
            the GPIB and some other I/O interfaces. When multiple remote
            programming interfaces are active, the interface with the most
            recently changed remote/local state determines the instrument’s
            remote/local state.
            The remote/local state is unaffected by *RST or any SCPI commands
            other than SYSTem:COMMunicate:RLState. At power-on however, the
            communications setting always returns to LOCal.
        """
        self.cmd = f"SYSTem:COMMunicate:RLSTate {mode}"
        return self.device.write_port(self.cmd)

    def get_communicate_mode(self):
        """
            This query returns the mode of the system - LOCal | REMote | RWLock
        """
        self.cmd = f"SYSTem:COMMunicate:RLSTate?"
        return self.device.read_port(self.cmd)

    def get_next_error_number(self):
        """
            This query returns the next error number and its corresponding
            message string from the error queue. The queue is a FIFO (first-in,
            first-out) buffer that stores errors as they occur. As it is read, each
            error is removed from the queue. When all errors have been read, the
            query returns 0, NO ERROR. If more errors are accumulated than the
            queue can hold, the last error in the queue will be -350, TOO MANY
            ERRORS (see Appendix C for error codes).
        """
        self.cmd = f"SYSTem:ERRor?"
        return self.device.read_port(self.cmd)

    # ************************************************************************************ #
    # ******************************* Source Commands ************************************ #
    # ************************************************************************************ #

    def set_current_level(self, value, channel=1):
        """
            These commands set the immediate and the triggered output current
            level. The values are programmed in amperes. The immediate level is
            the output current setting.
            :channel: integer. Desire channel
        """
        self.cmd = f"SOURce:CURRent {value}, (@{channel})"
        return self.device.write_port(self.cmd)

    def get_current_level(self, channel=1):
        """
            return the current level
            :channel: integer. Desire channel
        """
        self.cmd = f"SOURce:CURRent? (@{channel})"
        return self.device.read_port(self.cmd)

    def set_ocp_state(self, state):
        """
            This command enables or disables the over-current protection (OCP)
            function. The enabled state is On (1); the disabled state is Off (0). If
            the over-current protection function is enabled and the output goes
            into constant current operation, the output is disabled and OC is set
            in the Questionable Condition status register. The *RST value = Off.
            An over-current condition can be cleared with the Output Protection
            Clear command after the cause of the condition is removed.
        """
        mode = {'OFF': 0, 'ON': 1}
        self.cmd = f"SOURce:CURRent:PROTection:STATe {mode[state]}"
        return self.device.write_port(self.cmd)

    def get_ocp_state(self):
        """
            return the state of the OCP
        """
        self.cmd = f"SOURce:CURRent:PROTection:STATe?"
        return self.device.read_port(self.cmd)

    def set_voltage_level(self, value, channel=1):
        """
            These commands set the immediate and the triggered output voltage
            level. The values are programmed in volts. The immediate level is the
            output voltage setting.

            Model (V rating)   6V  8V  12.5V  20V  30V  40V  60V   80V  100V  150V  300V  600V
            Min. voltage level 0    0   0      0    0   0    0     0     0     0     0   0
            Max. voltage level 6.3 8.4 13.125 21   31.5 41.9 62.85 83.8 104.76 157.1 314.2 628.5
            :channel: integer. Desire channel
        """
        self.cmd = f"SOURce:VOLTage {value}, (@{channel})"
        return self.device.write_port(self.cmd)

    def get_voltage_level(self, channel=1):
        """
            return the voltage level
            :channel: integer. Desire channel
        """
        self.cmd = f"SOURce:VOLTage? (@{channel})"
        return self.device.read_port(self.cmd)

    def set_voltage_limit(self, value, channel=1):
        """
            This command sets the low voltage limit of the output. When a low
            voltage limit has been set, the instrument will ignore any
            programming commands that attempt to set the output voltage below
            the low voltage limit. The*RST value = Max.

            Model (V rating)   6V  8V  12.5V  20V  30V  40V  60V   80V  100V  150V  300V  600V
            Min. low limit      0    0   0      0    0   0    0     0     0     0     0   0
            Max. low limit      5.7 7.6 11.9    19  28.5 38   57    76    95    142   285 570
            :channel: integer. Desire channel
        """
        self.cmd = f"SOURce:VOLTage:LIMit:LOW {value}, (@{channel})"
        return self.device.write_port(self.cmd)

    def get_voltage_limit(self, channel=1):
        """
            return the voltage limit
            :channel: integer. Desire channel
        """
        self.cmd = f"SOURce:VOLTage:LIMit:LOW? (@{channel})"
        return self.device.read_port(self.cmd)

    # ************************************************************************************ #
    # ******************************* Trigger Commands ************************************ #
    # ************************************************************************************ #

    def abort(self):
        """
            This command cancels any trigger actions in progress and returns
            the trigger system to the IDLE state, unless INIT:CONT is enabled. It
            also resets the WTG bit in the Status Operation Condition register.
            ABORt is executed at power-on and upon execution of *RST.
        """
        self.cmd = f"ABORt"
        return self.device.write_port(self.cmd)


if __name__ == '__main__':
    """
    Test the driver
    """
    flag = 0
    ps = N6701A("192.168.1.14", 5025, "ps")
    ps.openPort()
    time.sleep(0.01)
    print(ps.get_idn())
    time.sleep(0.01)
    ps.set_output("OFF", channel=1)
    outputstate = int(ps.get_output(channel=1))
    print(f"outputstate: {outputstate}")
    if outputstate == 1:
        print("Fail to power off power supply")
    else:
        print("Power supply off")
        flag = 1
    ps.closePort()
    exit(flag)