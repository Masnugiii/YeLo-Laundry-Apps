"use client";

import { useQuery } from "@tanstack/react-query";
import { Card, CardTitle, CardValue } from "@/components/ui/card";
import { apiGet } from "@/lib/api";

interface PickupDeliveryDashboard {
  pickupRequested: number;
  driverAssigned: number;
  onTheWay: number;
  readyForDelivery: number;
  deliveredToday: number;
  failedDelivery: number;
  averageDeliveryTimeMinutes: number;
}

export default function PickupDeliveryPage() {
  const { data } = useQuery({
    queryKey: ["pickup-delivery-dashboard"],
    queryFn: () => apiGet<PickupDeliveryDashboard>("/pickup-delivery/dashboard"),
  });

  const metrics = data
    ? Object.entries(data).map(([key, value]) => [key, value])
    : [];

  return (
    <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
      {metrics.map(([title, value]) => (
        <Card key={String(title)}>
          <CardTitle>{String(title)}</CardTitle>
          <CardValue>{String(value)}</CardValue>
        </Card>
      ))}
    </div>
  );
}
