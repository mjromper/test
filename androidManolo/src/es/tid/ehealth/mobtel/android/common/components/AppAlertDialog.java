/*
 * Copyright (C) 2007 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package es.tid.ehealth.mobtel.android.common.components;

import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.database.Cursor;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.provider.ContactsContract;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Toast;
import es.tid.ehealth.mobtel.android.R;


/**
 * Example of how to use an {@link android.app.AlertDialog}.
 * <h3>AlertDialogSamples</h3>

<p>This demonstrates the different ways the AlertDialog can be used.</p>

<h4>Demo</h4>
App/Dialog/Alert Dialog

<h4>Source files</h4>
 * <table class="LinkTable">
 *         <tr>
 *             <td >src/com.example.android.apis/app/AlertDialogSamples.java</td>
 *             <td >The Alert Dialog Samples implementation</td>
 *         </tr>
 *         <tr>
 *             <td >/res/any/layout/alert_dialog.xml</td>
 *             <td >Defines contents of the screen</td>
 *         </tr>
 * </table> 
 */
public abstract class AppAlertDialog extends AppActivity {
	
	//private static final Logger logger = LoggerFactory.getLogger(AppAlertDialog.class);

	public static final int DIALOG_YES_NO_MESSAGE = 1;
    public static final int DIALOG_YES_NO_LONG_MESSAGE = 2;
    public static final int DIALOG_LIST = 3;
    public static final int DIALOG_PROGRESS = 4;
    public static final int DIALOG_SINGLE_CHOICE = 5;
    public static final int DIALOG_MULTIPLE_CHOICE = 6;
    public static final int DIALOG_TEXT_ENTRY = 7;
    public static final int DIALOG_MULTIPLE_CHOICE_CURSOR = 8;
    public static final int DIALOG_YES_NO_SOMTHING_LONG_MESSAGE = 9;

    private static final int MAX_PROGRESS = 100;

    private ProgressDialog mProgressDialog;
    private int mProgress;
    private Handler mProgressHandler;
    
    public static final String DIALOG_TYPE = "idDialogType";
    public static final String DIALOG_MESSAGE = "dialogMessage";
    public static final String DIALOG_TITLE = "dialogTitle";
	
    
	private int idDialogType = 0;	
	private String title = "";
	private String message = "";
	
	protected String labelOk = "Ok";
	protected String labelCancel = "Cancel";
	
	

	protected abstract void doOk();
	protected abstract void doCancel();	

    @Override
    protected Dialog onCreateDialog(int id) {
        switch (id) {
        case DIALOG_YES_NO_MESSAGE:
            return new AlertDialog.Builder(AppAlertDialog.this)
                .setIcon(R.drawable.icon)
                .setTitle(title)
                .setPositiveButton(labelOk, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int whichButton) {
                    	doOk();
                        /* User clicked OK so do some stuff */
                    }
                })
                .setNegativeButton(labelCancel, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int whichButton) {
                    	doCancel();
                        /* User clicked Cancel so do some stuff */
                    }
                })
                .create();
        case DIALOG_YES_NO_LONG_MESSAGE:
            return new AlertDialog.Builder(AppAlertDialog.this)
                .setIcon(R.drawable.icon)
                .setTitle(title)
                .setMessage(message)
                .setPositiveButton(labelOk, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int whichButton) {
                    	doOk();
                        /* User clicked OK so do some stuff */
                    }
                })
                .setNegativeButton(labelCancel, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int whichButton) {
                    	doCancel();
                        /* User clicked Cancel so do some stuff */
                    }
                })
                .create();
        case DIALOG_YES_NO_SOMTHING_LONG_MESSAGE:
            return new AlertDialog.Builder(AppAlertDialog.this)
                .setIcon(R.drawable.icon)
                .setTitle(title)
                .setMessage(message)
                .setPositiveButton(labelOk, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int whichButton) {
                    	doOk();
                        /* User clicked OK so do some stuff */
                    }
                })
                .setNeutralButton(R.string.alert_dialog_something, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int whichButton) {
                        /* User clicked Something so do some stuff */
                    }
                })
                .setNegativeButton(labelCancel, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int whichButton) {
                    	doCancel();
                        /* User clicked Cancel so do some stuff */
                    }
                })
                .create(); 
        case DIALOG_LIST:
            return new AlertDialog.Builder(AppAlertDialog.this)
                .setTitle(title)
                .setItems(R.array.select_dialog_items, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {

                        /* User clicked so do some stuff */
                        String[] items = getResources().getStringArray(R.array.select_dialog_items);
                        new AlertDialog.Builder(AppAlertDialog.this)
                                .setMessage("You selected: " + which + " , " + items[which])
                                .show();
                    }
                })
                .create();
        case DIALOG_PROGRESS:
            mProgressDialog = new ProgressDialog(AppAlertDialog.this);
            mProgressDialog.setIcon(R.drawable.icon);
            mProgressDialog.setTitle(title);
            mProgressDialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
            mProgressDialog.setMax(MAX_PROGRESS);
            mProgressDialog.setButton(DialogInterface.BUTTON_POSITIVE,
                    getText(R.string.alert_dialog_hide), new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int whichButton) {
                	
                    /* User clicked Yes so do some stuff */
                }
            });
            mProgressDialog.setButton(DialogInterface.BUTTON_NEGATIVE,labelCancel,
            		new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int whichButton) {
                	doCancel();
                    /* User clicked No so do some stuff */
                }
            });
            return mProgressDialog;
        case DIALOG_SINGLE_CHOICE:
            return new AlertDialog.Builder(AppAlertDialog.this)
                .setIcon(R.drawable.icon)
                .setTitle(title)
                .setSingleChoiceItems(R.array.select_dialog_items2, 0, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int whichButton) {

                        /* User clicked on a radio button do some stuff */
                    }
                })
                .setPositiveButton(labelOk, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int whichButton) {
                    	doOk();
                        /* User clicked Yes so do some stuff */
                    }
                })
                .setNegativeButton(labelCancel, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int whichButton) {
                    	doCancel();
                        /* User clicked No so do some stuff */
                    }
                })
               .create();
        case DIALOG_MULTIPLE_CHOICE:
            return new AlertDialog.Builder(AppAlertDialog.this)
                .setIcon(R.drawable.ic_popup_reminder)
                .setTitle(title)
                .setMultiChoiceItems(R.array.select_dialog_items3,
                        new boolean[]{false, true, false, true, false, false, false},
                        new DialogInterface.OnMultiChoiceClickListener() {
                            public void onClick(DialogInterface dialog, int whichButton,
                                    boolean isChecked) {

                                /* User clicked on a check box do some stuff */
                            }
                        })
                .setPositiveButton(labelOk,
                        new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int whichButton) {
                    	doOk();
                        /* User clicked Yes so do some stuff */
                    }
                })
                .setNegativeButton(labelCancel,
                        new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int whichButton) {
                    	doCancel();
                        /* User clicked No so do some stuff */
                    }
                })
               .create();
            case DIALOG_MULTIPLE_CHOICE_CURSOR:
                String[] projection = new String[] {
                        ContactsContract.Contacts._ID,
                        ContactsContract.Contacts.DISPLAY_NAME,
                        ContactsContract.Contacts.SEND_TO_VOICEMAIL
                };
                Cursor cursor = managedQuery(ContactsContract.Contacts.CONTENT_URI,
                        projection, null, null, null);
                return new AlertDialog.Builder(AppAlertDialog.this)
                    .setIcon(R.drawable.ic_popup_reminder)
                    .setTitle(title)
                    .setMultiChoiceItems(cursor,
                            ContactsContract.Contacts.SEND_TO_VOICEMAIL,
                            ContactsContract.Contacts.DISPLAY_NAME,
                            new DialogInterface.OnMultiChoiceClickListener() {
                                public void onClick(DialogInterface dialog, int whichButton,
                                        boolean isChecked) {
                                    Toast.makeText(AppAlertDialog.this,
                                            "Readonly Demo Only - Data will not be updated",
                                            Toast.LENGTH_SHORT).show();
                                }
                            })
                   .create();
        case DIALOG_TEXT_ENTRY:
            // This example shows how to add a custom layout to an AlertDialog
            LayoutInflater factory = LayoutInflater.from(this);
            final View textEntryView = factory.inflate(R.layout.alert_dialog_text_entry, null);
            return new AlertDialog.Builder(AppAlertDialog.this)
                .setIcon(R.drawable.icon)
                .setTitle(title)
                .setView(textEntryView)
                .setPositiveButton(labelOk, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int whichButton) {
                    	doOk();
                        /* User clicked OK so do some stuff */
                    }
                })
                .setNegativeButton(labelCancel, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int whichButton) {
                    	doCancel();
                        /* User clicked cancel so do some stuff */
                    }
                })
                .create();
        }
        return null;
    }

    /**
     * Initialization of the Activity after it is first created.  Must at least
     * call {@link android.app.Activity#setContentView(int)} to
     * describe what is to be displayed in the screen.
     */
    @Override
        protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        Bundle extras = getIntent().getExtras();
	    
        idDialogType  = extras.getInt(DIALOG_TYPE);
	    title = extras.getString(DIALOG_TITLE);
	    message = extras.getString(DIALOG_MESSAGE);
	    
	    int idIntType = Integer.valueOf(idDialogType);
	   
	    showDialog(idIntType);	    
	         
        mProgressHandler = new Handler() {
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);
                if (mProgress >= MAX_PROGRESS) {
                    mProgressDialog.dismiss();
                } else {
                    mProgress++;
                    mProgressDialog.incrementProgressBy(1);
                    mProgressHandler.sendEmptyMessageDelayed(0, 100);
                }
            }
        };
    }
    
    protected void setButtonLabels(String okLabel, String cancelLabel){
    	labelOk = okLabel;
    	labelCancel = cancelLabel;
    }
    	
}
