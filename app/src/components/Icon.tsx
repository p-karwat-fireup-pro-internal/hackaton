import React from "react";
import Svg, { Path, Circle } from "react-native-svg";

export type IconName =
  | "lightning"
  | "droplet"
  | "snowflake"
  | "hammer"
  | "wrench"
  | "check"
  | "play"
  | "alert-triangle"
  | "chevron-right"
  | "cloud-off"
  | "refresh-cw"
  | "phone"
  | "map-pin"
  | "clock"
  | "plus";

type IconProps = {
  name: IconName;
  size?: number;
  color?: string;
  strokeWidth?: number;
};

const paths: Record<IconName, React.ReactNode> = {
  lightning: (
    <Path
      d="M13 2 L4 14 L12 14 L11 22 L20 10 L12 10 L13 2 Z"
      fill="currentColor"
      stroke="none"
    />
  ),
  droplet: (
    <Path
      d="M12 2.5 C12 2.5 5 10 5 15 a7 7 0 0 0 14 0 c0 -5 -7 -12.5 -7 -12.5 Z"
      fill="currentColor"
      stroke="none"
    />
  ),
  snowflake: (
    <Path
      d="M12 2 v20 M2 12 h20 M5 5 l14 14 M19 5 l-14 14"
      fill="none"
      strokeLinecap="round"
    />
  ),
  hammer: (
    <Path
      d="M14 4 L20 10 L17 13 L11 7 Z M11 7 L3 15 a2 2 0 0 0 0 3 l1 1 a2 2 0 0 0 3 0 L15 11"
      fill="currentColor"
      stroke="none"
    />
  ),
  wrench: (
    <Path
      d="M14.7 6.3 a4 4 0 0 1 5 5 l-9 9 a2 2 0 0 1 -3 0 l-2 -2 a2 2 0 0 1 0 -3 l9 -9 Z M9 11 l-5 5"
      fill="none"
      strokeLinecap="round"
      strokeLinejoin="round"
    />
  ),
  check: (
    <Path
      d="M4 12 L9 17 L20 6"
      fill="none"
      strokeLinecap="round"
      strokeLinejoin="round"
    />
  ),
  play: (
    <Path
      d="M7 4 L20 12 L7 20 Z"
      fill="currentColor"
      stroke="none"
      strokeLinejoin="round"
    />
  ),
  "alert-triangle": (
    <Path
      d="M12 3 L22 20 H2 Z M12 10 V14 M12 17 V17.5"
      fill="none"
      strokeLinecap="round"
      strokeLinejoin="round"
    />
  ),
  "chevron-right": (
    <Path
      d="M9 6 L15 12 L9 18"
      fill="none"
      strokeLinecap="round"
      strokeLinejoin="round"
    />
  ),
  "cloud-off": (
    <Path
      d="M3 3 L21 21 M9 5 a5 5 0 0 1 9 3 a4 4 0 0 1 1 7.8 M5 9 a4 4 0 0 0 1 7.5 H15"
      fill="none"
      strokeLinecap="round"
      strokeLinejoin="round"
    />
  ),
  "refresh-cw": (
    <Path
      d="M21 12 a9 9 0 1 1 -3 -6.7 M21 4 V10 H15"
      fill="none"
      strokeLinecap="round"
      strokeLinejoin="round"
    />
  ),
  phone: (
    <Path
      d="M5 4 H8 L10 9 L7.5 10.5 a11 11 0 0 0 6 6 L15 14 L20 16 V19 a2 2 0 0 1 -2 2 a16 16 0 0 1 -15 -15 a2 2 0 0 1 2 -2 Z"
      fill="none"
      strokeLinecap="round"
      strokeLinejoin="round"
    />
  ),
  "map-pin": (
    <>
      <Path
        d="M12 22 s-7 -7.5 -7 -13 a7 7 0 0 1 14 0 c0 5.5 -7 13 -7 13 Z"
        fill="none"
        strokeLinejoin="round"
      />
      <Circle cx={12} cy={9} r={2.5} fill="none" />
    </>
  ),
  clock: (
    <>
      <Circle cx={12} cy={12} r={9} fill="none" />
      <Path
        d="M12 7 V12 L15 14"
        fill="none"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </>
  ),
  plus: (
    <Path
      d="M12 5 V19 M5 12 H19"
      fill="none"
      strokeLinecap="round"
    />
  ),
};

export function Icon({
  name,
  size = 20,
  color = "currentColor",
  strokeWidth = 2,
}: IconProps) {
  return (
    <Svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke={color}
      strokeWidth={strokeWidth}
      // currentColor in path fill resolves at runtime — RN-svg uses `color` prop
      color={color}
    >
      {paths[name]}
    </Svg>
  );
}

export const categoryIcon: Record<
  "elektryka" | "hydraulika" | "klimatyzacja" | "stolarka" | "ogolne",
  IconName
> = {
  elektryka: "lightning",
  hydraulika: "droplet",
  klimatyzacja: "snowflake",
  stolarka: "hammer",
  ogolne: "wrench",
};
