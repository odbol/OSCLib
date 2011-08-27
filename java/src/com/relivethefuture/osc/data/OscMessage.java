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
import java.util.Iterator;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * @author Martin Wood-Mitrovski
 */
public class OscMessage implements OscPacket {
	final Logger logger = LoggerFactory.getLogger(OscMessage.class);

	protected String address;
	protected ArrayList<Object> arguments;
	protected String typeTags;

	private int datasize = 0;

	public OscMessage() {
		super();
		arguments = new ArrayList<Object>();
		typeTags = ",";
	}

	public OscMessage(String newAddress) {
		address = newAddress;
		arguments = new ArrayList<Object>();
		typeTags = ",";
	}

	public String getAddress() {
		return address;
	}

	public void setAddress(String anAddress) {
		address = anAddress;
	}

	public void addArgument(Object argument) {
		if (argument instanceof String) {
			addArgument((String) argument);
		} else if (argument instanceof Float) {
			addArgument((Float) argument);
		} else if (argument instanceof Integer) {
			addArgument((Integer) argument);
		} else if (argument instanceof BigInteger) {
			addArgument((BigInteger) argument);
		} else if (argument instanceof byte[]) {
			addArgument((byte[]) argument);
		} else if (argument instanceof Boolean) {
			addArgument((Boolean) argument);
		}
	}

	public void addArgument(Object[] array, String objectTypes) {
		typeTags += '[' + objectTypes + ']';
		arguments.add(array);
		// TODO : Compute datasize for array contents
	}

	public void addArgument(String param) {
		typeTags += 's';
		arguments.add(param);
		int stringSize = getStringSize(param);
		datasize += stringSize;
		logger.debug("Added string : " + param + " : " + stringSize + " : "
				+ datasize);
	}

	public void addArgument(Float f) {
		typeTags += 'f';
		arguments.add(f);
		datasize += 4;
	}

	public void addArgument(Integer i) {
		typeTags += 'i';
		arguments.add(i);
		datasize += 4;
		logger.debug("Added Int " + i + " : " + datasize);
	}

	public void addArgument(BigInteger b) {
		typeTags += 'h';
		arguments.add(b);
		datasize += 8;
	}

	public void addArgument(char c) {
		typeTags += 'c';
		arguments.add(c);
		datasize += 4;
	}

	public void addArgument(Boolean b) {
		typeTags += b ? 'T' : 'F';
		arguments.add(b);
	}

	public void addArgument(byte[] bytes) {
		typeTags += 'b';
		arguments.add(bytes);
		int dataLength = bytes.length;
		// An int32 size count,
		datasize += 4;
		// followed by that many 8-bit bytes of arbitrary binary data,
		datasize += dataLength;
		// followed by 0-3 additional zero bytes to make the total number of
		// bits a multiple of 32.
		int mod = (dataLength % 4);
		datasize += (mod > 0) ? 4 - mod : 0;
	}

	public ArrayList<Object> getArguments() {
		return arguments;
	}

	public String getTypeTags() {
		return typeTags;
	}

	public String toString() {
		String s = address;
		if (arguments.size() > 0) {
			s += " | ";
			for (Iterator<Object> i = arguments.iterator(); i.hasNext();) {
				Object arg = (Object) i.next();
				s += arg.toString() + " , ";
			}
			s += " | ";
		}
		return s;
	}

	public boolean isBundle() {
		return false;
	}

	public boolean isValid() {
		return address.length() > 0;
	}

	private int getStringSize(String str) {
		// Add 1 because a string must be zero terminated
		int len = str.length() + 1;
		// logger.debug("GetStringSize : " + str + " : " + len);
		int mod = len % 4;
		// logger.debug("MOD " + mod);
		int pad = (mod > 0) ? 4 - mod : 0;
		// logger.debug("PAD " + pad);
		return len + pad;
	}

	public int getSize() {
		int addr = getStringSize(address);
		int types = getStringSize(typeTags);
		// logger.debug("Get Size : " + addr + " : " + types + " : " +
		// datasize);
		return addr + types + datasize;
	}

}