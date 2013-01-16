/*
A nice wrapper class to control the Rainbowduino 

(c) copyright 2009 by rngtng - Tobias Bielohlawek
(c) copyright 2010/2011/2012 by Michael Vogt/neophob.com 
http://code.google.com/p/rainbowduino-firmware/wiki/FirmwareFunctionsReference

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General
Public License along with this library; if not, write to the
Free Software Foundation, Inc., 59 Temple Place, Suite 330,
Boston, MA  02111-1307  USA
 */

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import processing.core.PApplet;
import processing.serial.Serial;

import com.neophob.lpd6803.misc.ColorFormat;
import com.neophob.lpd6803.misc.MD5;

private static final Logger LOG = Logger.getLogger(SerialSend.class.getName());

/**
 * library to communicate with an LPD6803 stripes via serial port<br>
 * <br><br>
 * part of the neorainbowduino library.
 *
 * @author Michael Vogt / neophob.com
 */
public class SerialSend {
		
	/** The app. */
	private PApplet app;

	/** The baud. */
	private int baud = 115200;
	
	/** The port. */
	private Serial port;
	
	/** The arduino heartbeat. */
	private long arduinoHeartbeat;
	
	/** The ack errors. */
	private long ackErrors = 0;
	
	/** The arduino buffer size. */
	private int arduinoBufferSize;
	
	//logical errors reported by arduino, TODO: rename to lastErrorCode
	/** The arduino last error. */
	private int arduinoLastError;
	
	//connection errors to arduino, TODO: use it!
	/** The connection error counter. */
	private int connectionErrorCounter;
		
	/** map to store checksum of image. */
	private Map<Byte, String> lastDataMap;
	
	/** internal buffer, how many pixels are controlled */
  	private int pixelBuffer;
    

	/**
	 * Create a new instance to communicate with the lpd6803 device.
	 *
	 * @param app the app
	 * @throws NoSerialPortFoundException the no serial port found exception
	 */
	public SerialSend(PApplet app, int pixelBuffer) throws NoSerialPortFoundException {
		this(app, null, 0, pixelBuffer);
	}

	/**
	 * Create a new instance to communicate with the lpd6803 device.
	 *
	 * @param app the app
	 * @param baud the baud
	 * @throws NoSerialPortFoundException the no serial port found exception
	 */
	public SerialSend(PApplet app, int baud, int pixelBuffer) throws NoSerialPortFoundException {
		this(app, null, baud, pixelBuffer);
	}

	/**
	 * Create a new instance to communicate with the lpd6803 device.
	 *
	 * @param app the app
	 * @param portName the port name
	 * @throws NoSerialPortFoundException the no serial port found exception
	 */
	public SerialSend(PApplet app, String portName, int pixelBuffer) throws NoSerialPortFoundException {
		this(app, portName, 0, pixelBuffer);
	}


	/**
	 * Create a new instance to communicate with the lpd6803 device.
	 *
	 * @param _app the _app
	 * @param portName the port name
	 * @param baud the baud
	 * @throws NoSerialPortFoundException the no serial port found exception
	 */
	public SerialSend(PApplet app, String portName, int baud, int pixelBuffer) throws NoSerialPortFoundException {
		
		LOG.log(Level.INFO,	"Initialize SerialSend lib");
		
		this.app = app;
		app.registerDispose(this);
		
		this.pixelBuffer = pixelBuffer;
		lastDataMap = new HashMap<Byte, String>();
		
		String serialPortName="";
		if(baud > 0) {
			this.baud = baud;
		}
		
		if (portName!=null && !portName.trim().isEmpty()) {
			//open specific port
			LOG.log(Level.INFO,	"open port: {0}", portName);
			serialPortName = portName;
			openPort(portName);
		} else {
			//try to find the port
			String[] ports = Serial.list();
			for (int i=0; port==null && i<ports.length; i++) {
				LOG.log(Level.INFO,	"open port: {0}", ports[i]);
				try {
					serialPortName = ports[i];
					openPort(ports[i]);
				//catch all, there are multiple exception to catch (NoSerialPortFoundException, PortInUseException...)
				} catch (Exception e) {
					// search next port...
				}
			}
		}
				
		if (port==null) {
			throw new NoSerialPortFoundException("Error: no serial port found!");
		}
		
		LOG.log(Level.INFO,	"found serial port: "+serialPortName);
	}


	/**
	 * clean up library.
	 */
	public void dispose() {
		if (connected()) {
			port.stop();
		}
	}


	/**
	 * return connection state of lib.
	 *
	 * @return whether a lpd6803 device is connected
	 */
	public boolean connected() {
		return (port != null);
	}	

	

	/**
	 * Open serial port with given name. Send ping to check if port is working.
	 * If not port is closed and set back to null
	 *
	 * @param portName the port name
	 * @throws NoSerialPortFoundException the no serial port found exception
	 */
	private void openPort(String portName) throws NoSerialPortFoundException {
		if (portName == null) {
			return;
		}
		try {
			port = new Serial(app, portName, this.baud);
			sleep(1500); //give it time to initialize
			if (sendFrame(new byte[64])) {
				return;
			}
			LOG.log(Level.WARNING, "No response from port {0}", portName);
			if (port != null) {
				port.stop();        					
			}
			port = null;
			throw new NoSerialPortFoundException("No response from port "+portName);
		} catch (Exception e) {	
			LOG.log(Level.WARNING, "Failed to open port {0}: {1}", new Object[] {portName, e});
			if (port != null) {
				port.stop();        					
			}
			port = null;
			throw new NoSerialPortFoundException("Failed to open port "+portName+": "+e);
		}	
	}


	
	
	

	
	/**
	 * send a frame to the active lpd6803 device.
	 *
	 * @param ofs - the offset 
	 * @param data byte[3*8*4]
	 * @return true if send was successful
	 * @throws IllegalArgumentException the illegal argument exception
	 */
	public boolean sendFrame(byte data[]) throws IllegalArgumentException {		
		//hint: the arduino serial buffer is 128bytes
		if (data == null || data.length!=64) {
			throw new IllegalArgumentException("data lenght must be 64 bytes!");
		}
	      
		try {
                  writeSerialData(data);                
                  return true;
		} catch (Exception e) {
                  return false;
		}		

	}
	
	

	
	/**
	 * get last error code from arduino
	 * if the errorcode is between 100..109 - serial connection issue (pc-arduino issue)
	 * if the errorcode is < 100 it's a i2c lib error code (arduino-rainbowduino error)
	 *    check http://arduino.cc/en/Reference/WireEndTransmission for more information
	 *   
	 * @return last error code from arduino
	 */
	public int getArduinoErrorCounter() {
		return arduinoLastError;
	}

	/**
	 * return the serial buffer size of the arduino
	 * 
	 * the buffer is by default 128 bytes - if the buffer is most of the
	 * time almost full (>110 bytes) you probabely send too much serial data.
	 *
	 * @return arduino filled serial buffer size
	 */
	public int getArduinoBufferSize() {
		return arduinoBufferSize;
	}

	/**
	 * per default arduino update this library each 3s with statistic information
	 * this value save the timestamp of the last message.
	 * 
	 * @return timestamp when the last heartbeat receieved. should be updated each 3s.
	 */
	public long getArduinoHeartbeat() {
		return arduinoHeartbeat;
	}
	
	
	/**
	 * how may times the serial response was missing / invalid.
	 *
	 * @return the ack errors
	 */
	public long getAckErrors() {
		return ackErrors;
	}

	/**
	 * send the data to the serial port.
	 *
	 * @param cmdfull the cmdfull
	 * @throws SerialPortException the serial port exception
	 */
	private synchronized void writeSerialData(byte[] cmdfull) throws SerialPortException {
		//TODO handle the 128 byte buffer limit!
		if (port==null) {
			throw new SerialPortException("port is not ready!");
		}
		
		//log.log(Level.INFO, "Serial Wire Size: {0}", cmdfull.length);

		try {
			port.output.write(cmdfull);
			port.output.flush();
			//DO NOT flush the buffer... hmm not sure about this, processing flush also
			//and i discovered strange "hangs"...
		} catch (Exception e) {
			LOG.log(Level.INFO, "Error sending serial data!", e);
			connectionErrorCounter++;
			throw new SerialPortException("cannot send serial data, errorNr: "+connectionErrorCounter+", Error: "+e);
		}		
	}
	




	/**
	 * Sleep wrapper.
	 *
	 * @param ms the ms
	 */
	private void sleep(int ms) {
		try {
			Thread.sleep(ms);
		}
		catch(InterruptedException e) {
		}
	}
	



}
