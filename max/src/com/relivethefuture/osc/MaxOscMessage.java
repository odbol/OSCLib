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
package com.relivethefuture.osc;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Iterator;

import com.cycling74.max.Atom;
import com.relivethefuture.osc.data.OscMessage;

public class MaxOscMessage extends OscMessage
{
	private ArrayList<Atom> arguments;

	public MaxOscMessage()
	{
		arguments = new ArrayList<Atom>();
	}
	
	public void addArgument(String param)
	{
		arguments.add(Atom.newAtom(param));
	}

	public void addArgument(Float f)
	{
		arguments.add(Atom.newAtom(f));
	}

	public void addArgument(Integer i)
	{
		arguments.add(Atom.newAtom(i));
	}

	public void addArgument(BigInteger b)
	{
		arguments.add(Atom.newAtom(b.longValue()));
	}

	public void addArgument(char c)
	{
		arguments.add(Atom.newAtom(c));
	}

	public void addArgument(Boolean b)
	{
		arguments.add(Atom.newAtom(b));		
	}

	public Atom[] getAtoms()
	{
		Atom[] args = new Atom[arguments.size()];
		int pos = 0;
		for (Iterator<Atom> i = arguments.iterator(); i.hasNext();)
		{
			Atom atom = (Atom) i.next();
			args[pos++] = atom;
		}
		return args;
	}
}
