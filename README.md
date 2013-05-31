# VSTimeMetrics - simple code execution time profiler class

VSTimeMetrics allows to record code execution time in multithreaded applications. Each measurement is a named action, so you can accumulate values for the same part of code to get total or average time of execution.

The source code of VSTimeMetrics is distributed under [MIT License](http://en.wikipedia.org/wiki/MIT_License). See file LICENSE for more information.

## Main features

- key-based profiling
- functions for getting last, average and total measurement time
- thread safe with read-write locks

## usage example

``` obj-c
VSTimeMetrics *m = [VSTimeMetrics sharedInstance];
[m startMeasuringForKey:@"loading file"];
// load file code
[m finishMeasuringForKey:@"loading file"];
NSLog(@"file load time: %f", [m lastMeasurementForKey:@"loading file"]);
```

For threaded example see [VSTimeMetricsTest](https://github.com/silvansky/VSTimeMetricsTest) project.