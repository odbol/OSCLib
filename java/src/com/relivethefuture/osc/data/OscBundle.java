/**
 * Copyright (c) 2008 Martin Wood-Mitrovski
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package com.relivethefuture.osc.data;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;

/**
 * OSC Bundle.
 * 
 * Time tags are represented by a 64 bit fixed point number. The first 32 bits
 * specify the number of seconds since midnight on January 1, 1900, and the last
 * 32 bits specify fractional parts of a second to a precision of about 200
 * picoseconds. This is the representation used by Internet NTP timestamps. The
 * time tag value consisting of 63 zero bits followed by a one in the least
 * signifigant bit is a special case meaning "immediately."
 * 
 */
public class OscBundle implements OscPacket {
	/**
	 * Time from 1900 to 1970 in seconds
	 */
	public static final BigInteger SECONDS_TO_EPOCH = new BigInteger(
			"2208988800");
	public static final Date IMMEDIATELY = new Date(0);
	public static final String BUNDLE_HEADER = "#bundle";

	protected Date timestamp;
	protected ArrayList<OscPacket> packets;

	private int size;

	/**
	 * Create a new empty OSCBundle with a timestamp of immediately. You can add
	 * packets to the bundle with addPacket()
	 */
	public OscBundle() {
		this(null, IMMEDIATELY);
	}

	public OscBundle(Date timestamp) {
		this(null, timestamp);
	}

	public OscBundle(ArrayList<OscPacket> packets) {
		this(packets, IMMEDIATELY);
	}

	public OscBundle(ArrayList<OscPacket> packets, Date timestamp) {
		// Default size is 16 bytes.
		// 8 bytes #bundle header and 8 bytes timestamp
		size = 16;
		if (packets != null) {
			for (Iterator<OscPacket> i = packets.iterator(); i.hasNext();) {
				OscPacket oscPacket = (OscPacket) i.next();
				addPacket(oscPacket);
			}
		} else {
			this.packets = new ArrayList<OscPacket>();
		}

		this.timestamp = timestamp;
	}

	public Date getTimestamp() {
		return timestamp;
	}

	public void setTimestamp(Date timestamp) {
		this.timestamp = timestamp;
	}

	public void addPacket(OscPacket packet) {
		packets.add(packet);
		
		//since bundles (and TCP) connections also send their size, we have to make room for each one!
		size += packet.getSize() + 4;
	}

	public ArrayList<OscPacket> getPackets() {
		return packets;
	}

	public boolean isBundle() {
		return true;
	}

	/**
	 * For a bundle to be valid it must have a timestamp and have some packets
	 * inside. Otherwise there is no point sending it.
	 */
	public boolean isValid() {
		return timestamp != null && packets.size() > 0;
	}

	public int getSize() {
		
		//since bundles (and TCP) connections also send their size, we have to make room for each one!
		//got through all messages in bundle and add 4 bytes each
		//if (packet.isBundle()) {
		//	size += ((OscBundle)packet).getPackets().size() * 4;
		//}
		return size;
	}
}