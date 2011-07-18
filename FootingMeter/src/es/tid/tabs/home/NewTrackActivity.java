package es.tid.tabs.home;


import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.RadioGroup;
import android.widget.RadioGroup.OnCheckedChangeListener;
import es.tid.R;
import es.tid.tabs.TabGroupActivity;

public class NewTrackActivity extends Activity {
	private EditText runningName;
	private RadioGroup radioGroup;


	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.new_track_layout);

		// trackName = (Button) findViewById(R.id.newTrackTrackName);
		runningName = (EditText) findViewById(R.id.newTrackRunningName);

		radioGroup = (RadioGroup) findViewById(R.id.radiotype);
		radioGroup.setOnCheckedChangeListener(new OnCheckedChangeListener() {

			public void onCheckedChanged(RadioGroup group, int checkedId) {
				if(group.getCheckedRadioButtonId() == R.id.radiobybike){
					UtilsFooting.market = R.drawable.icon_bike;
				}else if (group.getCheckedRadioButtonId() == R.id.radioonfoot){
					UtilsFooting.market = R.drawable.icon_run;
				}

			}
		});

		final Button nextBtn = (Button) findViewById(R.id.start_btn);
		OnClickListener nextBtnListener = new OnClickListener() {
			@Override
			public void onClick(View v) {
				// elena
				// UtilsStride.trackName =
				// trackName.getSelectedItem().toString();
				UtilsFooting.runningName = runningName.getText().toString();		

				TabGroupActivity parentActivity = (TabGroupActivity) getParent();
				Intent intent = new Intent(parentActivity,
						RunningActivity.class);
				parentActivity.startChildActivity("RunningActivity",
						intent);			

			}
		};

		nextBtn.setOnClickListener(nextBtnListener);
	}




}
