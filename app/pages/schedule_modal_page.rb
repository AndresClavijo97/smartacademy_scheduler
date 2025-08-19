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

  def schedule(lesson)
    within_schedule_frame do
      execute(find_by_number_js(lesson.number))
      click_assign_button
    end
  end

  private

  # click en el boton 'Asignar'
  def click_assign_button
    find_and_click "#BUTTON1"
  end

  # TODO: move this to capybara.rb
  def configure_timeouts
    Capybara.current_session.driver.browser.manage.timeouts.script_timeout = SCRIPT_TIMEOUT_SECONDS
  end

  def within_schedule_frame(&block)
    within_frame(find("#gxp0_ifrm")) do
      yield
    end
  end

  def find_by_number_js(class_number)
    <<~JS
      (async () => {
        const MAPPINGS = { claseNo: 4 };
        const PAGE_LOAD_DELAY_MS = 2000;
        const MAX_PAGES = 27;

        // Buscar y hacer click en el row
        const findAndClick = () => {
          const rows = document.querySelectorAll('tr[id*="Grid1ContainerRow"]');

          for (const row of rows) {
            const cells = row.querySelectorAll('td');
            const num = parseInt(cells[MAPPINGS.claseNo]?.textContent?.trim());

            if (num === #{class_number}) {
              row.click();
              row.style.backgroundColor = '#ffeb3b'; // Visual feedback
              return true;
            }
          }
          return false;
        };

        // Buscar en página actual
        if (findAndClick()) return true;

        // Si no está, navegar páginas
        for (let i = 0; i < MAX_PAGES; i++) {
          const nextBtn = document.querySelector('.PagingButtonsNext');
          if (!nextBtn || nextBtn.disabled) break;

          nextBtn.click();
          await new Promise(r => setTimeout(r, PAGE_LOAD_DELAY_MS));

          if (findAndClick()) return true;
        }

        return false;
      })();
    JS
  end

  def extract_lessions
    <<~JS
      (async () => {
        const MAPPINGS = { nivel: 3, claseNo: 4, descripcion: 5, estado: 10 };

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
