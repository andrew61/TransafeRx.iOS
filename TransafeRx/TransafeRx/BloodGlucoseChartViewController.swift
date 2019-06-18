//
//  BloodGlucoseChartViewController.swift
//  TransafeRx
//
//  Created by Tachl on 8/18/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import Charts

class BloodGlucoseChartViewController: UIViewController{
    
    var xValues = [String]()
    var yValues = [Double]()
    var measurements = [BloodGlucoseMeasurement]()
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Blood Glucose"
        
        tableView.dataSource = self
        tableView.alpha = 0.0
        chartView.delegate = self
        chartView.chartDescription?.text = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let calendar = Calendar(identifier: .gregorian)
        var startDate = Date()
        
        var startDateComp = calendar.dateComponents([.hour, .minute, .year, .month, .day], from: startDate)
        
        startDateComp.hour = 0
        startDateComp.minute = 0
        
        startDate = calendar.date(from: startDateComp)!.subtractDays(daysToSubtract: 30.0)
        
        showProgress()
        ApiManager.sharedManager.getBloodGlucoseMeasurementChart(model: ChartModel(startDate: startDate, endDate: Date(), aggregate: 1)) { (measurements, error) in
            self.dismissProgress()
            self.yValues.removeAll()
            self.xValues.removeAll()
            for measurement in measurements{
                self.yValues.append(Double(measurement.Glucose!))
                self.xValues.append(measurement.ReadingDateUTC!.date)
                self.loadChart(dataPoints: self.xValues, values: self.yValues)
            }
        }
        
        ApiManager.sharedManager.getBloodGlucoseMeasurements { (measurements, error) in
            self.measurements = measurements
            self.tableView.reloadData()
        }
        return
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        return
    }
    
    override func viewWillDisappear(_ animated: Bool){
        return
    }
    
    override func viewDidDisappear(_ animated: Bool){
        super.viewDidDisappear(animated)
    }
    
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            tableView.alpha = 0.0
            chartView.alpha = 1.0
        }else{
            tableView.alpha = 1.0
            chartView.alpha = 0.0
        }
    }
    
    func loadChart(dataPoints: [String], values: [Double]){
        chartView.noDataText = "You need to provide data for the chart."
        
        let xAxis: XAxis = XAxis()
        xAxis.setLabelCount(dataPoints.count, force: true)
        
        let xAxisValueFormatter = LineXAxisValueFormatter(values: xValues)
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count{
            let dataEntry = ChartDataEntry(x: Double(i), y: yValues[i])
        
            dataEntries.append(dataEntry)
        
            xAxisValueFormatter.stringForValue(Double(i), axis: xAxis)
        }
        
        xAxis.valueFormatter = xAxisValueFormatter
        chartView.xAxis.valueFormatter = xAxisValueFormatter
        
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "Glucose")
        chartDataSet.mode = .linear
        chartDataSet.axisDependency = .left
        chartDataSet.setColor(UIColor.blue.withAlphaComponent(0.5))
        chartDataSet.setCircleColor(UIColor.blue)
        chartDataSet.valueFont = .systemFont(ofSize: 12.0)
        
        var chartDataSets : [LineChartDataSet] = [LineChartDataSet]()
        chartDataSets.append(chartDataSet)
        
        let chartData = LineChartData(dataSets: chartDataSets)
        
        chartView.setVisibleXRangeMaximum(4.0)
        chartView.legend.enabled = true
        chartView.xAxis.granularityEnabled = true
        chartView.xAxis.drawGridLinesEnabled = true
        chartView.xAxis.setLabelCount(dataPoints.count, force: true)
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelFont = .systemFont(ofSize: 8.0)
        chartView.xAxis.labelRotationAngle = 45.0
        chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInBounce)
        chartView.backgroundColor = UIColor.white
        chartView.setVisibleXRangeMaximum(4.0)
        chartView.data = chartData
        chartView.setVisibleXRangeMaximum(4.0)
        chartView.data?.notifyDataChanged()
        chartView.notifyDataSetChanged()
        chartView.setVisibleXRangeMaximum(4.0)
    }
}

extension BloodGlucoseChartViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return measurements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let measurement = measurements[indexPath.row]
        
        cell.textLabel?.text = measurement.getMeasurement()
        
        return cell
    }
}

extension BloodGlucoseChartViewController: ChartViewDelegate{
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
    }
}
