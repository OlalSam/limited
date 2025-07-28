/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ignium.nganya.route.service;

import com.ignium.nganya.schedule.SchedulerService;
import jakarta.ejb.Schedule;
import jakarta.ejb.Startup;
import jakarta.inject.Inject;
import jakarta.inject.Singleton;
import java.time.LocalDate;

/**
 *
 * @author olal
 */
@Singleton
@Startup
public class AllocationJob {

    @Inject private SchedulerService scheduler;

    /**
     * Runs automatically at 00:30 every day.
     */
    @Schedule(hour="0", minute="30", persistent=false)
    public void onTimeout() {
        scheduler.allocateAndGenerate(LocalDate.now());
        
    }
}
