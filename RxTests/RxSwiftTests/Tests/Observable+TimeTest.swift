
//
//  Observable+TimeTest.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/23/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import XCTest

class ObservableTimeTest : RxTest {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
}

// throttle

extension ObservableTimeTest {
    func test_ThrottleTimeSpan_AllPass() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 0),
            next(210, 1),
            next(240, 2),
            next(270, 3),
            next(300, 4),
            completed(400)
            ])
        
        let res = scheduler.start {
            xs >- throttle(20, scheduler)
        }
        
        let correct = [
            next(230, 1),
            next(260, 2),
            next(290, 3),
            next(320, 4),
            completed(400)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        let subscriptions = [
            Subscription(200, 400)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
    }
    
    func test_ThrottleTimeSpan_AllPass_ErrorEnd() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 0),
            next(210, 1),
            next(240, 2),
            next(270, 3),
            next(300, 4),
            error(400, testError)
            ])
        
        let res = scheduler.start {
            xs >- throttle(20, scheduler)
        }
        
        let correct = [
            next(230, 1),
            next(260, 2),
            next(290, 3),
            next(320, 4),
            error(400, testError)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        let subscriptions = [
            Subscription(200, 400)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
    }
    
    func test_ThrottleTimeSpan_AllDrop() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 0),
            next(210, 1),
            next(240, 2),
            next(270, 3),
            next(300, 4),
            next(330, 5),
            next(360, 6),
            next(390, 7),
            completed(400)
            ])
        
        let res = scheduler.start {
            xs >- throttle(40, scheduler)
        }
        
        let correct = [
            next(400, 7),
            completed(400)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        let subscriptions = [
            Subscription(200, 400)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
    }
    
    func test_ThrottleTimeSpan_AllDrop_ErrorEnd() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 0),
            next(210, 1),
            next(240, 2),
            next(270, 3),
            next(300, 4),
            next(330, 5),
            next(360, 6),
            next(390, 7),
            error(400, testError)
            ])
        
        let res = scheduler.start {
            xs >- throttle(40, scheduler)
        }
        
        let correct: [Recorded<Int>] = [
            error(400, testError)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        let subscriptions = [
            Subscription(200, 400)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
    }
    
    func test_ThrottleEmpty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 0),
            completed(300)
            ])
        
        let res = scheduler.start {
            xs >- throttle(10, scheduler)
        }
        
        let correct: [Recorded<Int>] = [
            completed(300)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        let subscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
    }
    
    func test_ThrottleError() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 0),
            error(300, testError)
            ])
        
        let res = scheduler.start {
            xs >- throttle(10, scheduler)
        }
        
        let correct: [Recorded<Int>] = [
            error(300, testError)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        let subscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
    }
    
    func test_ThrottleNever() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 0),
            ])
        
        let res = scheduler.start {
            xs >- throttle(10, scheduler)
        }
        
        let correct: [Recorded<Int>] = [
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        let subscriptions = [
            Subscription(200, 1000)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
    }
    
    func test_ThrottleSimple() {
        let scheduler = TestScheduler(initialClock: 0)
       
        let xs = scheduler.createHotObservable([
            next(150, 0),
            next(210, 1),
            next(240, 2),
            next(250, 3),
            next(280, 4),
            completed(300)
            ])
        
        let res = scheduler.start {
            xs >- throttle(20, scheduler)
        }
        
        let correct: [Recorded<Int>] = [
            next(230, 1),
            next(270, 3),
            next(300, 4),
            completed(300)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        let subscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
    }
}

// sample

extension ObservableTimeTest {
    func testSample_Sampler_SamplerThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            next(240, 3),
            next(290, 4),
            next(300, 5),
            next(310, 6),
            completed(400)
            ])
        
        let ys = scheduler.createHotObservable([
            next(150, ""),
            next(210, "bar"),
            next(250, "foo"),
            next(260, "qux"),
            error(320, testError)
            ])
        
        let res = scheduler.start {
            xs >- sample(ys)
        }
        
        let correct: [Recorded<Int>] = [
            next(250, 3),
            error(320, testError)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 320)
        ])

        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 320)
        ])
    }
    
    func testSample_Sampler_Simple1() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            next(240, 3),
            next(290, 4),
            next(300, 5),
            next(310, 6),
            completed(400)
            ])
        
        let ys = scheduler.createHotObservable([
            next(150, ""),
            next(210, "bar"),
            next(250, "foo"),
            next(260, "qux"),
            next(320, "baz"),
            completed(500)
            ])
        
        let res = scheduler.start {
            xs >- sample(ys)
        }
        
        let correct: [Recorded<Int>] = [
            next(250, 3),
            next(320, 6),
            completed(500)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 500)
            ])
    }
    
    func testSample_Sampler_Simple2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            next(240, 3),
            next(290, 4),
            next(300, 5),
            next(310, 6),
            next(360, 7),
            completed(400)
            ])
        
        let ys = scheduler.createHotObservable([
            next(150, ""),
            next(210, "bar"),
            next(250, "foo"),
            next(260, "qux"),
            next(320, "baz"),
            completed(500)
            ])
        
        let res = scheduler.start {
            xs >- sample(ys)
        }
        
        let correct: [Recorded<Int>] = [
            next(250, 3),
            next(320, 6),
            next(500, 7),
            completed(500)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 500)
            ])
    }
    
    func testSample_Sampler_Simple3() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            next(240, 3),
            next(290, 4),
            completed(300)
            ])
        
        let ys = scheduler.createHotObservable([
            next(150, ""),
            next(210, "bar"),
            next(250, "foo"),
            next(260, "qux"),
            next(320, "baz"),
            completed(500)
            ])
        
        let res = scheduler.start {
            xs >- sample(ys)
        }
        
        let correct: [Recorded<Int>] = [
            next(250, 3),
            next(320, 4),
            completed(320)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 320)
            ])
    }
    
    func testSample_Sampler_SourceThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            next(240, 3),
            next(290, 4),
            next(300, 5),
            next(310, 6),
            error(320, testError)
            ])
        
        let ys = scheduler.createHotObservable([
            next(150, ""),
            next(210, "bar"),
            next(250, "foo"),
            next(260, "qux"),
            next(300, "baz"),
            completed(400)
            ])
        
        let res = scheduler.start {
            xs >- sample(ys)
        }
        
        let correct: [Recorded<Int>] = [
            next(250, 3),
            next(300, 5),
            error(320, testError)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 320)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 320)
            ])
    }
    
    func testSampleLatest_Sampler_SamplerThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            next(240, 3),
            next(290, 4),
            next(300, 5),
            next(310, 6),
            completed(400)
            ])
        
        let ys = scheduler.createHotObservable([
            next(150, ""),
            next(210, "bar"),
            next(250, "foo"),
            next(260, "qux"),
            error(320, testError)
            ])
        
        let res = scheduler.start {
            xs >- sampleLatest(ys)
        }
        
        let correct: [Recorded<Int>] = [
            next(250, 3),
            next(260, 3),
            error(320, testError)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 320)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 320)
            ])
    }
    
    func testSampleLatest_Sampler_Simple1() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            next(240, 3),
            next(290, 4),
            next(300, 5),
            next(310, 6),
            completed(400)
            ])
        
        let ys = scheduler.createHotObservable([
            next(150, ""),
            next(210, "bar"),
            next(250, "foo"),
            next(260, "qux"),
            next(320, "baz"),
            completed(500)
            ])
        
        let res = scheduler.start {
            xs >- sampleLatest(ys)
        }
        
        let correct: [Recorded<Int>] = [
            next(250, 3),
            next(260, 3),
            next(320, 6),
            next(500, 6),
            completed(500)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 500)
            ])
    }
    
    func testSampleLatest_Sampler_Simple2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            next(240, 3),
            next(290, 4),
            next(300, 5),
            next(310, 6),
            next(360, 7),
            completed(400)
            ])
        
        let ys = scheduler.createHotObservable([
            next(150, ""),
            next(210, "bar"),
            next(250, "foo"),
            next(260, "qux"),
            next(320, "baz"),
            completed(500)
            ])
        
        let res = scheduler.start {
            xs >- sampleLatest(ys)
        }
        
        let correct: [Recorded<Int>] = [
            next(250, 3),
            next(260, 3),
            next(320, 6),
            next(500, 7),
            completed(500)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 500)
            ])
    }
    
    func testSampleLatest_Sampler_Simple3() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            next(240, 3),
            next(290, 4),
            completed(300)
            ])
        
        let ys = scheduler.createHotObservable([
            next(150, ""),
            next(210, "bar"),
            next(250, "foo"),
            next(260, "qux"),
            next(320, "baz"),
            completed(500)
            ])
        
        let res = scheduler.start {
            xs >- sampleLatest(ys)
        }
        
        let correct: [Recorded<Int>] = [
            next(250, 3),
            next(260, 3),
            next(320, 4),
            completed(320)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 320)
            ])
    }
    
    func testSampleLatest_Sampler_SourceThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            next(240, 3),
            next(290, 4),
            next(300, 5),
            next(310, 6),
            error(320, testError)
            ])
        
        let ys = scheduler.createHotObservable([
            next(150, ""),
            next(210, "bar"),
            next(250, "foo"),
            next(260, "qux"),
            next(300, "baz"),
            completed(400)
            ])
        
        let res = scheduler.start {
            xs >- sampleLatest(ys)
        }
        
        let correct: [Recorded<Int>] = [
            next(250, 3),
            next(260, 3),
            next(300, 5),
            error(320, testError)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 320)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 320)
            ])
    }
}

// interval

extension ObservableTimeTest {
    
    func testInterval_TimeSpan_Basic() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let res = scheduler.start {
            interval(100, scheduler)
        }
        
        let correct: [Recorded<Int64>] = [
            next(300, 0),
            next(400, 1),
            next(500, 2),
            next(600, 3),
            next(700, 4),
            next(800, 5),
            next(900, 6)
        ]
        
        XCTAssertEqual(res.messages, correct)
    }
    
    func testInterval_TimeSpan_Zero() {
        let scheduler = PeriodicTestScheduler(initialClock: 0)
        
        let res = scheduler.start(210) {
            interval(0, scheduler)
        }
        
        let correct: [Recorded<Int64>] = [
            next(201, 0),
            next(202, 1),
            next(203, 2),
            next(204, 3),
            next(205, 4),
            next(206, 5),
            next(207, 6),
            next(208, 7),
            next(209, 8),
        ]
        
        XCTAssertEqual(res.messages, correct)
    }
    
    func testInterval_TimeSpan_Zero_DefaultScheduler() {
        var scheduler = DispatchQueueScheduler(globalConcurrentQueuePriority: .Default)
        
        let observer = PrimitiveMockObserver<Int64>()
        
        var lock = OS_SPINLOCK_INIT
        
        OSSpinLockLock(&lock)
        
        let d = interval(0, scheduler) >- takeWhile { $0 < 10 } >- subscribe(next: { t in
            sendNext(observer, t)
        }, error: { _ in
        }, completed: {
            OSSpinLockUnlock(&lock)
        }) >- scopedDispose
        
        OSSpinLockLock(&lock)
        OSSpinLockUnlock(&lock)
        
        scheduler.schedule(()) { _ in
            OSSpinLockUnlock(&lock)
            return NopDisposableResult
        }

        // wait until dispatch queue cleans it's resources
        OSSpinLockLock(&lock)
        
        XCTAssertTrue(observer.messages.count == 10)
        
    }
    
    func testInterval_TimeSpan_Disposed() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let res = scheduler.start {
            interval(1000, scheduler)
        }
        
        let correct: [Recorded<Int64>] = [
         
        ]
        
        XCTAssertEqual(res.messages, correct)
        
    }
}

// take

extension ObservableTimeTest {
    
    func testTake_TakeZero() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(210, 1),
            next(220, 2),
            completed(230)
        ])
        
        let res = scheduler.start {
            xs >- take(0, scheduler)
        }
        
        XCTAssertEqual(res.messages, [
            completed(201)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 201)
            ])
    }
    
    func testTake_Some() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(210, 1),
            next(220, 2),
            next(230, 3),
            completed(240)
            ])
        
        let res = scheduler.start {
            xs >- take(25, scheduler)
        }
        
        XCTAssertEqual(res.messages, [
            next(210, 1),
            next(220, 2),
            completed(225)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 225)
            ])
    }
    
    func testTake_TakeLate() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(210, 1),
            next(220, 2),
            completed(230),
            ])
        
        let res = scheduler.start {
            xs >- take(50, scheduler)
        }
        
        XCTAssertEqual(res.messages, [
            next(210, 1),
            next(220, 2),
            completed(230)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
            ])
    }
    
    func testTake_TakeError() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(0, 0),
            error(210, testError)
            ])
        
        let res = scheduler.start {
            xs >- take(50, scheduler)
        }
        
        XCTAssertEqual(res.messages, [
            error(210, testError),
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 210)
            ])
    }
    
    func testTake_TakeNever() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(0, 0),
            ])
        
        let res = scheduler.start {
            xs >- take(50, scheduler)
        }
        
        XCTAssertEqual(res.messages, [
            completed(250)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    func testTake_TakeTwice1() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(210, 1),
            next(220, 2),
            next(230, 3),
            next(240, 4),
            next(250, 5),
            next(260, 6),
            completed(270)
            ])
        
        let res = scheduler.start {
            xs >- take(35, scheduler)
        }
        
        XCTAssertEqual(res.messages, [
            next(210, 1),
            next(220, 2),
            next(230, 3),
            completed(235)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 235)
            ])
    }

    func testTake_TakeDefault() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(210, 1),
            next(220, 2),
            next(230, 3),
            next(240, 4),
            next(250, 5),
            next(260, 6),
            completed(270)
            ])
        
        let res = scheduler.start {
            xs >- take(35, scheduler)
        }
        
        XCTAssertEqual(res.messages, [
            next(210, 1),
            next(220, 2),
            next(230, 3),
            completed(235)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 235)
            ])
    }

}

// take

extension ObservableTimeTest {
    
    func testDelaySubscription_TimeSpan_Simple() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createColdObservable([
            next(50, 42),
            next(60, 43),
            completed(70)
            ])
        
        let res = scheduler.start {
            xs >- delaySubscription(30, scheduler)
        }
        
        XCTAssertEqual(res.messages, [
            next(280, 42),
            next(290, 43),
            completed(300)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(230, 300)
        ])
    }
    
    func testDelaySubscription_TimeSpan_Error() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createColdObservable([
            next(50, 42),
            next(60, 43),
            error(70, testError)
            ])
        
        let res = scheduler.start {
            xs >- delaySubscription(30, scheduler)
        }
        
        XCTAssertEqual(res.messages, [
            next(280, 42),
            next(290, 43),
            error(300, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(230, 300)
            ])
    }
    
    func testDelaySubscription_TimeSpan_Dispose() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createColdObservable([
            next(50, 42),
            next(60, 43),
            error(70, testError)
            ])
        
        let res = scheduler.start(291) {
            xs >- delaySubscription(30, scheduler)
        }
        
        XCTAssertEqual(res.messages, [
            next(280, 42),
            next(290, 43),
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(230, 291)
            ])
    }
}