class SchedulePage < ApplicationPage
  PROGRAM_CODE = "INGA1C1"

  def open_scheduler
    select_course
    # Hacer clic en el botón "iniciar" que lleva al scheduler
    find("#W0030BUTTON1").click
  end

  def go_to_timetable
    # Hacer clic en el botón "Horario"
    find("#BUTTON2").click
  end

  private

  def select_course(program_code = PROGRAM_CODE)
    # Seleccionar la fila del curso por su código
    find("tr[data-gxrow='0001']").click
  end

  def start_scheduling
    # Hacer clic en el botón "Iniciar"
    find("#W0030BUTTON1").click
  end
end
