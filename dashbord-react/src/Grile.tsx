import React, { useState } from 'react';
import { Button } from '@/components/ui/button';

interface Tab {
  id: string;
  label: string;
}

const tabs: Tab[] = [
  { id: 'teme', label: 'Teme' },
  { id: 'suplimentare', label: 'Teste suplimentare' },
  { id: 'combinate', label: 'Teste combinate' },
  { id: 'simulari', label: 'Simulări' },
  { id: 'ani', label: 'Grile date în anii anteriori' },
];

export default function Grile() {
  const [active, setActive] = useState<string>(tabs[0].id);

  const renderTab = () => {
    switch (active) {
      case 'teme':
        return <div></div>;
      case 'suplimentare':
        return <div></div>;
      case 'combinate':
        return <div></div>;
      case 'simulari':
        return <div></div>;
      case 'ani':
        return <div></div>;
      default:
        return null;
    }
  };

  return (
    <div className="space-y-4">
      <div className="border-b mb-4 space-x-2">
        {tabs.map((t) => (
          <Button
            key={t.id}
            variant={active === t.id ? 'default' : 'secondary'}
            onClick={() => setActive(t.id)}
          >
            {t.label}
          </Button>
        ))}
      </div>
      {renderTab()}
    </div>
  );
}
