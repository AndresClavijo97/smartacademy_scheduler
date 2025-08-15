class ScheduleModalPage < ApplicationPage
  def wait_for_modal
    has_selector?('.modal, .dialog, [role="dialog"], .gxwebcomponent', wait: 10)
  end

  def select_schedule_option(option_text)
    # Seleccionar una opción de horario específica
    find('option', text: option_text).select_option
  end

  def select_start_date(date)
    # Seleccionar fecha de inicio del curso
    date_field = find('input[type="date"], input[id*="fecha"], input[id*="date"]')
    date_field.set(date)
  end

  def confirm_schedule
    # Confirmar la programación
    find('input[type="submit"], button[id*="confirm"], input[value*="Confirmar"]').click
  end

  def cancel_schedule
    # Cancelar la programación
    find('input[value*="Cancelar"], button[id*="cancel"]').click
  end

  def get_available_schedules
    # Obtener los horarios disponibles del modal
    schedule_options = []
    all('select option, .schedule-option').each do |option|
      schedule_options << option.text.strip unless option.text.strip.empty?
    end
    schedule_options
  end

  def has_schedule_conflict?
    has_text?('conflicto', 'Conflicto', 'CONFLICTO') ||
    has_text?('ocupado', 'Ocupado', 'OCUPADO')
  end

  def get_error_message
    error_element = find('.error, .alert, [id*="error"]', wait: 2)
    error_element.text if error_element
  rescue Capybara::ElementNotFound
    nil
  end

  def close_modal
    # Cerrar el modal usando X, botón cerrar o ESC
    begin
      find('.close, .modal-close, [aria-label="Close"]').click
    rescue Capybara::ElementNotFound
      # Si no hay botón de cerrar, intentar con ESC
      find('body').send_keys(:escape)
    end
  end

  def modal_title
    find('.modal-title, .dialog-title, h1, h2', wait: 2).text
  rescue Capybara::ElementNotFound
    'Modal'
  end
end