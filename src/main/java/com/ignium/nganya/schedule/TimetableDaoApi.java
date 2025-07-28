/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package com.ignium.nganya.schedule;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

/**
 *
 * @author olal
 */
interface TimetableDaoApi {

    boolean saveTimetable(int routeId, LocalDate serviceDate, List<LocalTime> departures);

    List<Timetable> findByServiceDate(LocalDate date);
}
