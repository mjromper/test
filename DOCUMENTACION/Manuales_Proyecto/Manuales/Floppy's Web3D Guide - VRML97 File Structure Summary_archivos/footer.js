function navbuttons(parent_url, prev_url, next_url) {
	document.write('<CENTER>\n');
	if (prev_url!='') {
		document.write('<A HREF="'+prev_url+'">');
		document.write('<IMG SRC="../pics/prev.gif" ALT="Prev" BORDER=0></A> ');
	}
	if (parent_url!='') {
		document.write('<A HREF="'+parent_url+'">');
		document.write('<IMG SRC="../pics/up.gif" ALT="Up" BORDER=0></A> ');
	}
	if (next_url!='') {
		document.write('<A HREF="'+next_url+'">');
		document.write('<IMG SRC="../pics/next.gif" ALT="Next" BORDER=0></A> ');
	}
	document.write('</CENTER>\n');
}

function footer(image_url, parent_name, parent_url, language, path) {

	document.write('<HR>');
	document.write('<TABLE BORDER="0" WIDTH="100%">');

	document.write('<TD>');
	if (parent_url) document.write('<A HREF="' + parent_url + '">');
        document.write('<IMG SRC="' + image_url + '" BORDER="0" ALT="' + parent_name + '" ALIGN=ABSMIDDLE>');
       	if (parent_url) document.write('</A>');
        document.write('</TD>');
	document.write('<TD><FONT SIZE="-1"><STRONG>&copy; <A HREF="http://web3d.vapourtech.com/legal.html">Copyright</A> 1998-2001 Vapour Technology Ltd. - <A HREF="mailto:&#103;&#117;&#105;&#100;e&#64;&#119;e&#98;&#51;&#100;g&#117;i&#100;&#101;&#46;&#111;&#114;g&#46;&#117;&#107;">&#103;&#117;&#105;&#100;e&#64;&#119;e&#98;&#51;&#100;g&#117;i&#100;&#101;&#46;&#111;&#114;g&#46;&#117;&#107;</A></STRONG>');

	if (language == 'es') document.write('<BR>Traducido por <A href="http://www5.ewebcity.com/maelmori/traductores.htm" target="_blank">Jose Luis Pumarega, Martin Zimmermann y Ram&oacute;n Ortiz</a>');
	
	document.write(Modified('<BR><EM>Last modified: ','</EM>'));
	
	document.write('</FONT></TD>');
	document.write('<TD ALIGN="RIGHT"><A HREF="http://www.vapourtech.com/" TARGET="_blank"><IMG SRC="' + path + '/pics/vapour.gif" BORDER="0" HEIGHT="25" WIDTH="130" ALT="Vapour Technology Ltd."></A></TD>');
	document.write('</TABLE>');
}

function Modified(start,end) {
	d=Date.parse(document.lastModified);
	if (d>0) {
		m=new Date(d); 
		y=m.getYear(); 
		if (y<100) y+=2000; 
		if (y<1900) y+= 1900;
		return(start+m.getDate()+'/'+(m.getMonth()+1)+'/'+y+end);
	}
	else return("");
}
