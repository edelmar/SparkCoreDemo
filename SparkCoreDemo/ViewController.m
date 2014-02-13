//
//  ViewController.m
//  SparkCorePatternBlinkTest
//
//  Created by Eric G. DelMar on 1/27/14.
//  Copyright (c) 2014 Eric G. DelMar. All rights reserved.
//

#define CORE1_ID @"5555555555555555555"
#define CORE1_token @"999999999999999999999999"
#import "ViewController.h"
#import "SparkCore.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *getTempButton;
@property (weak, nonatomic) IBOutlet UIButton *singleButton;
@property (weak, nonatomic) IBOutlet UIButton *doubleButton;
@property (weak, nonatomic) IBOutlet UIButton *tripleButton;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (strong,nonatomic) NSDateFormatter *formatter;
@property (strong,nonatomic) SparkCore *core1;
@end

@implementation ViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.label.text = @"";
    self.formatter = [NSDateFormatter new];
    self.formatter.dateFormat = @"h:mm a  MMM d, yyyy";
    
    self.core1 = [SparkCore coreNamed:@"Core1" userName:@"<Spark user name here>" password:@"<password here>"];
    //Or use this method:
   // self.core1 = [SparkCore coreWithdeviceID:CORE1_ID accessToken:CORE1_token];
    self.core1.delegate = self;
}


-(void)deviceIDWasSet { // delegate method from SparkCore class, called when the device ID has been retreived and set.
    self.getTempButton.enabled = YES;
    self.singleButton.enabled = YES;
    self.doubleButton.enabled = YES;
    self.tripleButton.enabled = YES;
}


-(IBAction)startBlinking:(UIButton *)sender { // connected to 3 buttons with titles "Single", "Double", "Triple"

    [self.core1 executeFunction:@"patternBlink"
                       argument:[sender.titleLabel.text lowercaseString]
                     returnKeys:@[@"value1", @"value2", @"value3", @"value4"]
              completionHandler:^(NSDictionary *result, NSError *error){
                  
        if (! error) {
            NSLog(@"result was %@", result);
        }else{
            NSLog(@"%@",error);
        }
    }];
}


-(IBAction)downloadTemperature:(UIButton *)sender {
    
    [self.core1 readInt:@"temperature" completionHandler:^(int result, NSError *error) {
        if (! error) {
            float temp = ((result * 3.3/4096) - 0.5) * 100;
            temp = temp * 9/5.0 + 32;
            NSString *dateString = [self.formatter stringFromDate:[NSDate date]];
            self.label.text = [NSString stringWithFormat:@"Temp: %.1f degrees Fahrenheit\nTime: %@",temp,dateString];
        }else{
            self.label.text = [NSString stringWithFormat:@"%@",error];
        }
    }];
}

/*
 
 Spark Program
 
 int ledControl(String command);
 int blueLED = D7;
 int temperature = 0;
 
 void setup() {
 Spark.function("patternBlink", ledControl);
 pinMode(blueLED, OUTPUT);
 digitalWrite(blueLED,LOW);
 Spark.variable("temperature", &temperature, INT);
 pinMode(A0, INPUT);
 }
 
 
 
 void loop() {
 static int i = 0;
 if (i == 0) {
 digitalWrite(blueLED, HIGH);
 delay(2000);
 digitalWrite(blueLED, LOW);
 i++;
 }
 temperature = analogRead(A0);
 }
 
 
 
 int ledControl(String command) {
 int counter = 0;
 while (counter < 3) {
 if (command == "single") {
 digitalWrite(blueLED, HIGH);
 delay(100);
 digitalWrite(blueLED, LOW);
 }else if (command == "double") {
 digitalWrite(blueLED, HIGH);
 delay(100);
 digitalWrite(blueLED, LOW);
 delay(200);
 digitalWrite(blueLED, HIGH);
 delay(100);
 digitalWrite(blueLED, LOW);
 }else if (command == "triple") {
 digitalWrite(blueLED, HIGH);
 delay(100);
 digitalWrite(blueLED, LOW);
 delay(200);
 digitalWrite(blueLED, HIGH);
 delay(100);
 digitalWrite(blueLED, LOW);
 delay(200);
 digitalWrite(blueLED, HIGH);
 delay(100);
 digitalWrite(blueLED, LOW);
 }
 delay(1000);
 counter++;
 }
 
 return 2147483647;
 }
 
 */

@end
