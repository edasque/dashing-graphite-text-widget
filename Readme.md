## Description

[Dashing](http://shopify.github.io/dashing/) widget to show the value of a graphite metric, change in the last 7 days and a sparkline of the metric over 30 days.

## Installation

- Download [jquery.sparklines.js](http://omnipotent.net/jquery.sparkline/#s-about) into the `assets/javascripts` folder
- Finally create a dashboard and use the Timer widget. Dont' forget to set your timer, title & graphite_host:

```html
<li data-row="1" data-col="1" data-sizex="1" data-sizey="1">
      <div data-view="Timer" data-timer="stats.timers.bob.startPage.rendered.mean"
      data-title="Campaign List" data-graphite_host="http://my.graphite.host"
       data-unit="ms"></div>
</li>
```

Include the ```data-debug=true``` property if you want some diagnostic information for a widget

## Screenshots

![Screenshot](https://www.evernote.com/shard/s2/sh/a6008697-d4d8-4f5c-871b-9a9428cbfb54/745eb34bc0c588791a33ee5dc93a5aa3/deep/0/Engineering-KPIs.png "Graphite Text & Sparkline Widget")
