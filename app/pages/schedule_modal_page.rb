class ScheduleModalPage < ApplicationPage
  private attr_reader :data

  # Timeout constants
  SCRIPT_TIMEOUT_SECONDS = 180
  PAGE_LOAD_DELAY_MS = 2000
  MAX_PAGES_LIMIT = 26

  def initialize
    @data = []
    configure_timeouts
  end

  def fetch_all_lessions
    within_schedule_frame { execute(extract_lessions) }
  end

  private

  # TODO: move this to capybara.rb
  def configure_timeouts
    Capybara.current_session.driver.browser.manage.timeouts.script_timeout = SCRIPT_TIMEOUT_SECONDS
  end

  def within_schedule_frame(&block)
    within_frame(find("#gxp0_ifrm")) do
      yield
    end
  end

  def extract_lessions
    <<~JS
      (async () => {
        const MAPPINGS = { nivel: 3, claseNo: 4, descripcion: 5, estado: 10 };
      #{'  '}
        const TYPE_PATTERNS = {
          intro: /intro/i,
          class: /clase/i,
          quiz_unit: /quiz\s*unit/i,
          smart_zone: /smart\s*zone/i,
          exam_prep: /preparaci[oó]n.*examen/i,
          final_exam: /examen\s*final/i
        };

        const STATUS_MAPPING = {
          'Pendiente': 'pending',
          'Programada': 'scheduled',
          'Programado': 'scheduled',
          'Tomada'    : 'completed',
          'Completada': 'completed',
          'Completado': 'completed',
          'Cancelada': 'cancelled',
          'Cancelado': 'cancelled',
          'En Curso': 'in_progress',
          'En curso': 'in_progress'
        };

        const determineKind = (description) =>#{' '}
          !description?.trim() ? 'unknown' :
          Object.entries(TYPE_PATTERNS).find(([_, pattern]) => pattern.test(description))?.[0] || 'other';

        const mapStatus = (spanishStatus) =>#{' '}
          STATUS_MAPPING[spanishStatus?.trim()] || 'pending';

        const extractRowData = (row, index, pageNum) => {
          const cellTexts = Array.from(row.querySelectorAll('td'), cell => cell.textContent?.trim() || '');
          const { nivel, claseNo, descripcion, estado } = MAPPINGS;
      #{'    '}
          return {
            html_row_id: row.id,
            level: cellTexts[nivel] || '',
            number: parseInt(cellTexts[claseNo]) || '',
            description: cellTexts[descripcion] || '',
            status: mapStatus(cellTexts[estado]),
            kind: determineKind(cellTexts[descripcion])
          };
        };

        const extractCurrentPage = (pageNum) =>#{' '}
          Array.from(document.querySelectorAll('tr[id*="Grid1ContainerRow"]'),#{' '}
                     (row, index) => extractRowData(row, index, pageNum));

        const hasNextPage = () => {
          const nextBtn = document.querySelector('.PagingButtonsNext');
          return nextBtn && !nextBtn.disabled;
        };

        const allData = [];
        let currentPage = 1;

        // Extraer todas las páginas
        do {
          const pageData = extractCurrentPage(currentPage);
          allData.push(...pageData);
          console.log(`Página ${currentPage}: ${pageData.length} filas`);

          if (hasNextPage()) {
            document.querySelector('.PagingButtonsNext').click();
            await new Promise(resolve => setTimeout(resolve, #{PAGE_LOAD_DELAY_MS})); // Esperar carga
            currentPage++;
          } else {
            break;
          }
        } while (currentPage <= #{MAX_PAGES_LIMIT}); // Límite de seguridad optimizado

        return allData;
      })();
    JS
  end
end
