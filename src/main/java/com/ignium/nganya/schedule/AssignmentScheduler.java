package com.ignium.nganya.schedule;

import jakarta.ejb.Schedule;
import jakarta.ejb.Singleton;
import jakarta.ejb.Startup;
import jakarta.inject.Inject;
import java.util.logging.Logger;

/**
 * Scheduler for handling automatic updates of vehicle assignments
 */
@Singleton
@Startup
public class AssignmentScheduler {
    
    private static final Logger logger = Logger.getLogger(AssignmentScheduler.class.getName());
    
    @Inject
    private ScheduleDao scheduleDao;
    
    /**
     * Runs daily at midnight to update expired assignments
     */
    @Schedule(hour = "7", minute = "38", second = "0", persistent = false)
    public void updateExpiredAssignments() {
        logger.info("Running scheduled update of expired assignments");
        scheduleDao.updateExpiredAssignments();
    }
} 