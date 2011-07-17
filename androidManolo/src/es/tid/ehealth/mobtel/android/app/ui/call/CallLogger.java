package es.tid.ehealth.mobtel.android.app.ui.call;

import java.util.Date;

import android.content.ContentResolver;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.provider.BaseColumns;
import android.provider.CallLog;

import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

public class CallLogger {

	private static final Logger logger = LoggerFactory.getLogger(CallLogger.class);
	
	private static boolean missedCall = false;
	private static boolean outgoingCall = false;
	private static boolean incomingCall = false;
	
	private static String number = "";

	private static Context context;
	

	public static void getLastCallLogEntry() { 

		setIncomingCall(false);
		setMissedCall(false);
		setOutgoingCall(false);
		
		String[] projection = new String[] { 
				BaseColumns._ID, 
				CallLog.Calls.NUMBER, 
				CallLog.Calls.TYPE, 
				CallLog.Calls.DURATION,
				CallLog.Calls.DATE
		}; 
		ContentResolver resolver = context.getContentResolver(); 
		Cursor cur = resolver.query( 
				CallLog.Calls.CONTENT_URI, 
				projection, 
				null, 
				null, 
				CallLog.Calls.DEFAULT_SORT_ORDER ); 
		int numberColumn = cur.getColumnIndex( CallLog.Calls.NUMBER ); 
		int typeColumn = cur.getColumnIndex( CallLog.Calls.TYPE ); 
		int durationcolumn = cur.getColumnIndex(CallLog.Calls.DURATION); 
		int datecolumn = cur.getColumnIndex(CallLog.Calls.DATE); 
		if( !cur.moveToNext()) { 
			cur.close(); 

		} 
		String number = cur.getString( numberColumn );		
		String type = cur.getString( typeColumn );
		String date = cur.getString(datecolumn);
		String dir = null; 
		try { 
			int dircode = Integer.parseInt( type ); 
			switch( dircode ) { 
			case CallLog.Calls.OUTGOING_TYPE: 
				setOutgoingCall(true);
				dir = "OUTGOING"; 
				break; 

			case CallLog.Calls.INCOMING_TYPE: 
				setIncomingCall(true);
				dir = "INCOMING"; 
				break; 

			case CallLog.Calls.MISSED_TYPE:
				setMissedCall(true);
				dir = "MISSED"; 
				break; 

			} 
		} catch( NumberFormatException ex ) {

		} 
		if( dir == null ){ 
			dir = "Unknown, code: "+type;
		}

		String duration = cur.getString(durationcolumn); 
		Date sDate = new Date(Long.valueOf(date));
		logger.debug("CallLog => "+dir+", number: "+number+ "("+duration+" sg), date = "+sDate);
		
		setNumber(number); 

	}
	
	
	public void deleteAnEntryFromCallLog(String number) 
	{ 
		try 
		{ 
			Uri CALLLOG_URI = Uri.parse("content://call_log/calls"); 
			context.getContentResolver().delete(CALLLOG_URI,CallLog.Calls.NUMBER +"=?",new String[]{number}); 
		} 
		catch(Exception e) 
		{ 
			logger.error("deleteAnEntryFromCallLog: "+e);
		
		} 
	}

	public static void setMissedCall(boolean missedCall) {
		CallLogger.missedCall = missedCall;
	}

	public static boolean isMissedCall(Context context) {
		CallLogger.context = context;
		getLastCallLogEntry();
		return missedCall;
	}

	public static void setOutgoingCall(boolean outgoingCall) {
		CallLogger.outgoingCall = outgoingCall;
	}

	public static boolean isOutgoingCall(Context context) {
		CallLogger.context = context;
		getLastCallLogEntry();
		return outgoingCall;
	}

	public static void setIncomingCall(boolean incomingCall) {
		CallLogger.incomingCall = incomingCall;
	}

	public static boolean isIncomingCall(Context context) {
		CallLogger.context = context;
		getLastCallLogEntry();
		return incomingCall;
	}

	public static void setNumber(String number) {
		CallLogger.number = number;
	}

	public static String getNumber() {
		return number;
	}

	

}
