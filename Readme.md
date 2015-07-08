## Description

[Dashing](http://shopify.github.io/dashing/) widget to show the value of a graphite metric, change in the last 7 days and a sparkline of the metric over 30 days.

## Installation

- Download [Moment.js](http://momentjs.com/downloads/moment.min.js), [jquery.sparklines.js](http://omnipotent.net/jquery.sparkline/#s-download) and [lodash.min.js](https://raw.githubusercontent.com/lodash/lodash/2.4.1/dist/lodash.min.js) and place them in the `assets/javascripts` folder
- Finally create a dashboard and use the Timer widget. Dont' forget to set your timer, title & graphite_host:

```html
<li data-row="1" data-col="1" data-sizex="1" data-sizey="1">
      <div data-view="Timer" data-metric="stats.timers.bob.startPage.rendered.mean"
      data-title="Campaign List" data-graphite_host="http://my.graphite.host"
       data-unit="ms"></div>
</li>
```

Include the ```data-debug=true``` property if you want some diagnostic information in the JS console for a widget

## Screenshots

![Screenshot](https://www.evernote.com/shard/s2/sh/a6008697-d4d8-4f5c-871b-9a9428cbfb54/745eb34bc0c588791a33ee5dc93a5aa3/deep/0/Engineering-KPIs.png "Graphite Text & Sparkline Widget")

## Changelog
* 10/16/14:
  * Added dependency install info in this readme and better exception handling in the code that points to missing dependencies.
  * Added data-debug as well and peppered the code for better diagnostic information as well.
  * Also will not display the sparkline & legend if there is less than 2 datapoints available.
  * Made unit text smaller. In earlier commit make empty string a valid metric
  * Renamed object propery timer to metric since we can show any metric
  * Ideally would rename the object
  * Cleaned up the SCSS file
