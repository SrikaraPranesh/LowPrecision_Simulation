%TEST Generates the tables and plots used in the 
% manuscript 'Simulating Low Precision Floating-Point
% Arithmetic -- N.J.Higham and S.Pranesh'

clear all; close all;

addpath('MainFunctions/')
addpath('MainScripts/')

euler_exp
LUTime;
euler_exp;
sum_series;
solve_test;
matmult;
demo_harmonic;
harmonic_series2;

movefile('*.txt','results')
movefile('*.mat','results')