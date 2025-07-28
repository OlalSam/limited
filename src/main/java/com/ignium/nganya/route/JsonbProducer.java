/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ignium.nganya.route;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.enterprise.inject.Disposes;
import jakarta.json.bind.Jsonb;
import jakarta.json.bind.JsonbBuilder;
import jakarta.enterprise.inject.Produces;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author olal
 */
@ApplicationScoped
public class JsonbProducer {
  @Produces
  public Jsonb createJsonb() {
    return JsonbBuilder.create();
  }
  public void close(@Disposes Jsonb jsonb) {
      try {
          jsonb.close();
      } catch (Exception ex) {
          Logger.getLogger(JsonbProducer.class.getName()).log(Level.SEVERE, null, ex);
      }
  }
}
