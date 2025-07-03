package com.sarveshmrao.lifeleft;

import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.widget.RemoteViews;
import android.widget.GridLayout;
import android.widget.ImageView;
import android.os.Build;
import android.view.View;
import java.util.Calendar;
import java.util.GregorianCalendar;

public class HeatmapWidgetProvider extends AppWidgetProvider {

    private static final int TOTAL_DAYS = 365; // Not handling leap years for simplicity
    private static final int COLUMNS = 20;

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int appWidgetId : appWidgetIds) {
            RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.widget_heatmap);

            Calendar now = Calendar.getInstance();
            int year = now.get(Calendar.YEAR);
            boolean isLeap = new GregorianCalendar().isLeapYear(year);
            int totalDays = isLeap ? 366 : 365;
            int todayOfYear = now.get(Calendar.DAY_OF_YEAR);
            int daysRemaining = totalDays - todayOfYear + 1; // +1 to include today

            // Set the days remaining text
            String daysText = daysRemaining + (daysRemaining == 1 ? " day remaining" : " days remaining");
            views.setTextViewText(R.id.days_remaining, daysText);

            // Remove all children first (for updates)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                views.removeAllViews(R.id.heatmap_grid);
            }

            for (int i = 0; i < totalDays; i++) {
                int resId;
                if (i + 1 == todayOfYear) {
                    resId = R.drawable.ic_heart_red;
                } else if (i + 1 < todayOfYear) {
                    resId = R.drawable.ic_heart_grey;
                } else {
                    resId = R.drawable.ic_heart_white;
                }

                RemoteViews heart = new RemoteViews(context.getPackageName(), R.layout.widget_heart_icon);
                heart.setImageViewResource(R.id.heart_icon, resId);

                views.addView(R.id.heatmap_grid, heart);
            }

            appWidgetManager.updateAppWidget(appWidgetId, views);
        }
    }
}