package es.tid.tabs.records;

import java.text.DateFormat;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;
import es.tid.R;
import es.tid.database.bo.Race;

public class ResultsAdapter extends BaseAdapter
{
	private BDResultsActivity activity;
	private ArrayList<Race> resultsList;
	private static DecimalFormat df = new DecimalFormat("0.###");


	public ResultsAdapter(BDResultsActivity activity, ArrayList<Race> racesList)
	{
		this.activity = activity;
		this.resultsList = racesList;
	}

	public int getCount()
	{
		return resultsList.size();
	}

	public Race getItem(int position)
	{
		return resultsList.get(position);
	}

	public long getItemId(int position)
	{
		return position;
	}

	public View getView(final int position, View convertView, ViewGroup viewGroup)
	{
		if (resultsList !=null){
			final Race entry = resultsList.get(position);
			if (convertView == null)
			{
				LayoutInflater inflater = (LayoutInflater) activity.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
				convertView = inflater.inflate(R.layout.bd_results_row, null);
			}

			TextView resultsName = (TextView) convertView.findViewById(R.id.resultsName);
			resultsName.setText(entry.getName());

			TextView resultsDate= (TextView) convertView.findViewById(R.id.resultsDate);
			SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
			Date date = new Date(entry.getDate());
			resultsDate.setText(sdf.format(date).toString());
			
			TextView duration = (TextView) convertView.findViewById(R.id.duration);
			if (entry.getDuration() != null){
				DateFormat df = new SimpleDateFormat("HH 'hours', mm 'mins,' ss 'seconds'");
				String time = df.format(new Date(entry.getDuration()));
				duration.setText(time);
			}
			
			TextView distance = (TextView) convertView.findViewById(R.id.distance);
			if (entry.getDistance() != null){
				distance.setText("Distance: "+df.format((double) entry.getDistance() / 1000) + " Km");
			}
		}

		return convertView;
	}
}
