package es.tid.gmaps;

import java.util.ArrayList;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.widget.Toast;

import com.google.android.maps.GeoPoint;
import com.google.android.maps.ItemizedOverlay;
import com.google.android.maps.MapView;
import com.google.android.maps.OverlayItem;

import es.tid.tabs.home.UtilsFooting;

public class HelloItemizedOverlay extends ItemizedOverlay<OverlayItem> {

	private ArrayList<OverlayItem> mOverlays = new ArrayList<OverlayItem>();
	private Context mContext;

	public HelloItemizedOverlay(Drawable defaultMarker, Context context) {
		super(boundCenterBottom(defaultMarker));
		mContext = context;
		populate(); // Add this
	}

	@Override
	protected OverlayItem createItem(int i) {
		return mOverlays.get(i);
	}

	@Override
	public int size() {
		return mOverlays.size();
	}

	public void addOverlay(OverlayItem overlay) {
		mOverlays.add(overlay);
		populate();
	}

	@Override
	protected boolean onTap(int index) {
		// TODO Auto-generated method stub
		Toast.makeText(mContext, "Location ("+ mOverlays.get(index).getPoint().getLatitudeE6()/UtilsFooting.GEO_CONV +", "+mOverlays.get(index).getPoint().getLongitudeE6()/UtilsFooting.GEO_CONV, Toast.LENGTH_SHORT).show();
		return super.onTap(index);         
	}

	@Override
	public boolean onTap(GeoPoint p, MapView mapView) {
		return super.onTap(p, mapView);
	}

	public void clear() {
		mOverlays.clear();
		populate();
	}


}
