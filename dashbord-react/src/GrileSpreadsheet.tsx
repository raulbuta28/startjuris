import React, { useState, useRef, useEffect } from 'react';
import { AgGridReact } from 'ag-grid-react';
import type { ColDef } from 'ag-grid-community';
import 'ag-grid-community/styles/ag-grid.css';
import 'ag-grid-community/styles/ag-theme-alpine.css';
import { Button } from '@/components/ui/button';

interface Sheet {
  name: string;
  columnDefs: ColDef[];
  rowData: Record<string, any>[];
}

export default function GrileSpreadsheet() {
  const rowNumberCol: ColDef = {
    headerName: '#',
    valueGetter: 'node.rowIndex + 1',
    width: 60,
    pinned: 'left',
    editable: false,
    suppressMovable: true,
    cellClass: 'ag-row-number'
  };

  const [sheets, setSheets] = useState<Sheet[]>([
    {
      name: 'Foaie 1',
      columnDefs: [rowNumberCol, { field: 'col1', headerName: 'Coloana 1', editable: true }],
      rowData: [{ col1: '' }],
    },
  ]);
  const [active, setActive] = useState(0);
  const [rowHeight, setRowHeight] = useState(30);
  const [editCols, setEditCols] = useState(false);
  const gridRef = useRef<AgGridReact<any>>(null);

  const addSheet = () => {
    setSheets((prev) => [
      ...prev,
      {
        name: `Foaie ${prev.length + 1}`,
        columnDefs: [rowNumberCol, { field: 'col1', headerName: 'Coloana 1', editable: true }],
        rowData: [{ col1: '' }],
      },
    ]);
    setActive(sheets.length);
  };

  const updateSheet = (index: number, update: Partial<Sheet>) => {
    setSheets((prev) => {
      const copy = [...prev];
      copy[index] = { ...copy[index], ...update } as Sheet;
      return copy;
    });
  };

  const addRow = () => {
    const current = sheets[active];
    const newRow: Record<string, any> = {};
    current.columnDefs.forEach((c) => {
      newRow[c.field as string] = '';
    });
    updateSheet(active, { rowData: [...current.rowData, newRow] });
  };

  const addColumn = () => {
    const current = sheets[active];
    const newField = `col${current.columnDefs.length}`;
    const newCol: ColDef = {
      field: newField,
      headerName: `Coloana ${current.columnDefs.length}`,
      editable: true,
    };
    const newRowData = current.rowData.map((r) => ({ ...r, [newField]: '' }));
    updateSheet(active, {
      columnDefs: [...current.columnDefs, newCol],
      rowData: newRowData,
    });
  };

  const renameColumn = (index: number, name: string) => {
    const current = sheets[active];
    const newCols = [...current.columnDefs];
    if (newCols[index]) {
      newCols[index] = { ...newCols[index], headerName: name };
      updateSheet(active, { columnDefs: newCols });
    }
  };

  useEffect(() => {
    const handlePaste = (e: ClipboardEvent) => {
      const text = e.clipboardData?.getData('text/plain');
      if (!text) return;
      const rows = text.trim().split(/\r?\n/).map((r) => r.split(/\t/));
      if (rows.length === 0) return;

      e.preventDefault();

      const current = sheets[active];
      let colsNeeded = rows[0].length - (current.columnDefs.length - 1);
      let updatedCols = [...current.columnDefs];
      let newRowData = [...current.rowData];

      for (let i = 0; i < colsNeeded; i++) {
        const field = `col${current.columnDefs.length + i}`;
        updatedCols.push({ field, headerName: `Coloana ${current.columnDefs.length + i}`, editable: true });
        newRowData = newRowData.map((r) => ({ ...r, [field]: '' }));
      }

      let rowsNeeded = rows.length - newRowData.length;
      for (let i = 0; i < rowsNeeded; i++) {
        const newRow: Record<string, any> = {};
        updatedCols.forEach((c) => {
          if (c.field) newRow[c.field as string] = '';
        });
        newRowData.push(newRow);
      }

      rows.forEach((r, ri) => {
        r.forEach((val, ci) => {
          const col = updatedCols[ci + 1];
          if (col && col.field) {
            newRowData[ri][col.field as string] = val;
          }
        });
      });

      updateSheet(active, { columnDefs: updatedCols, rowData: newRowData });
    };
    document.addEventListener('paste', handlePaste);
    return () => document.removeEventListener('paste', handlePaste);
  }, [sheets, active]);

  const onCellValueChanged = (params: any) => {
    const { rowIndex, colDef, newValue } = params;
    updateSheet(active, {
      rowData: sheets[active].rowData.map((row, idx) =>
        idx === rowIndex ? { ...row, [colDef.field as string]: newValue } : row
      ),
    });
  };

  return (
    <div className="p-4 space-y-4">
      <div className="flex space-x-2">
        {sheets.map((s, i) => (
          <Button
            key={i}
            variant={active === i ? 'default' : 'secondary'}
            size="sm"
            onClick={() => setActive(i)}
          >
            {s.name}
          </Button>
        ))}
        <Button variant="ghost" size="sm" onClick={addSheet}>
          +
        </Button>
      </div>
      <div className="space-x-2">
        <Button size="sm" onClick={addRow}>
          Adaugă rând
        </Button>
        <Button size="sm" onClick={addColumn}>
          Adaugă coloană
        </Button>
        <Button size="sm" onClick={() => setEditCols((v) => !v)}>
          {editCols ? 'Gata' : 'Editează numele coloanelor'}
        </Button>
        <label className="ml-2 text-sm">
          Înălțime rând:
          <input
            type="number"
            value={rowHeight}
            onChange={(e) => setRowHeight(Number(e.target.value))}
            className="ml-1 border p-1 w-16 text-sm"
          />
        </label>
      </div>
      {editCols && (
        <div className="space-x-2 mt-2">
          {sheets[active].columnDefs.slice(1).map((c, i) => (
            <input
              key={c.field as string}
              className="border p-1 text-sm"
              value={c.headerName as string}
              onChange={(e) => renameColumn(i + 1, e.target.value)}
            />
          ))}
        </div>
      )}
      <div className="ag-theme-alpine" style={{ width: '100%', height: 500 }}>
        <AgGridReact
          ref={gridRef}
          columnDefs={sheets[active].columnDefs}
          rowData={sheets[active].rowData}
          defaultColDef={{ editable: true, resizable: true, filter: true }}
          onCellValueChanged={onCellValueChanged}
          rowHeight={rowHeight}
        />
      </div>
    </div>
  );
}
