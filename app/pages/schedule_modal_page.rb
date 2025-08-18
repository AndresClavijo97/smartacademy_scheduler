class ScheduleModalPage < ApplicationPage
  private attr_reader :data

  def initialize
    @data = []
  end

  def find_next_available_class
    within_schedule_frame do    
      execute_js
    end
  end

  private

  def execute_js
    @data << evaluate_script(extract_rows_js)
  end

  def within_schedule_frame(&block)
    within_frame(find('#gxp0_ifrm')) do
      yield
    end
  end


  def extract_rows_js
    <<~JS
      (async () => {
        const MAPPINGS = { nivel: 3, claseNo: 4, descripcion: 5, nota: 7, estado: 10, fecha: 11, sede: 14 };
        
        const extractRowData = (row, index, pageNum) => {
          const cellTexts = Array.from(row.querySelectorAll('td'), cell => cell.textContent?.trim() || '');
          const { nivel, claseNo, descripcion, nota, estado, fecha, sede } = MAPPINGS;
          
          return {
            rowIndex: index + 1,
            rowId: row.id,
            pageNumber: pageNum,
            nivel: cellTexts[nivel],
            claseNo: cellTexts[claseNo],
            resumenDescripcion: cellTexts[descripcion],
            nota: parseFloat((cellTexts[nota] || '0').replace(',', '.')) || 0,
            estado: cellTexts[estado],
            fechaClase: cellTexts[fecha],
            nombreSede: cellTexts[sede]
          };
        };

        const extractCurrentPage = (pageNum) => 
          Array.from(document.querySelectorAll('tr[id*="Grid1ContainerRow"]'), 
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
            await new Promise(resolve => setTimeout(resolve, 4000)); // Esperar carga
            currentPage++;
          } else {
            break;
          }
        } while (currentPage <= 35); // Límite de seguridad

        return allData;
      })();
    JS
    # <<~JS
    #   (() => {
    #     const MAPPINGS = { nivel: 3, claseNo: 4, descripcion: 5, nota: 7, estado: 10, fecha: 11, sede: 14 };
                
    #     const extractRowData = (row, index) => {
    #       const cellTexts = Array.from(row.querySelectorAll('td'), cell => cell.textContent?.trim() || '');
    #       const { nivel, claseNo, descripcion, nota, estado, fecha, sede } = MAPPINGS;
          
    #       return {
    #         rowIndex: index + 1,
    #         rowId: row.id,
    #         nivel: cellTexts[nivel],
    #         claseNo: cellTexts[claseNo],
    #         resumenDescripcion: cellTexts[descripcion],
    #         nota: cellTexts[nota],
    #         estado: cellTexts[estado],
    #         fechaClase: cellTexts[fecha],
    #         nombreSede: cellTexts[sede]
    #       };
    #     };

    #     return Array.from(document.querySelectorAll('tr[id*="Grid1ContainerRow"]'), extractRowData);
    #   })();
    # JS
  end

  # def next_page
  #   evaluate_script("document.querySelector('.PagingButtonsNext').click();")
  # end
end