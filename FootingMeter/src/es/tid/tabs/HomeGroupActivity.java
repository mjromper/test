package es.tid.tabs;

import android.content.Intent;
import android.os.Bundle;
import es.tid.tabs.home.HomeActivity;

public class HomeGroupActivity extends TabGroupActivity {

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		startChildActivity("HomeActivity", new Intent(this, HomeActivity.class));
	}
}
