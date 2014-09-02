## Description

[Dashing](http://shopify.github.io/dashing/) widget to show the value of a graphite metric, change in the last 7 days and a sparkline of the metric over 30 days.

## Installation

- Download [jquery.sparklines.js](http://omnipotent.net/jquery.sparkline/#s-about) into the `assets/javascripts` folder
- Finally create a dashboard and use the Timer widget. Dont' forget to set your timer, title & graphite_host:

```html
<li data-row="1" data-col="1" data-sizex="1" data-sizey="1">
      <div data-view="Timer" data-timer="stats.timers.bob.startPage.rendered.mean" data-title="Campaign List" graphite_host="http://my.graphite.host" data-unit="ms"></div>
</li>
```

## Screenshots

